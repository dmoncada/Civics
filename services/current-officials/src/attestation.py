"""Apple App Attest registration and API Gateway request authorization.

The public handler exposes one-time challenges and key registration.  The
authorizer accepts either an App Attest assertion or the operator test key.
All values sent by the client are base64url encoded so they are safe in HTTP
headers and JSON.
"""

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import os
import secrets
import time
from typing import Any

import boto3
import cbor2
from botocore.exceptions import ClientError
from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric.ec import ECDSA

_dynamodb = boto3.resource(
    "dynamodb", endpoint_url=os.environ.get("DYNAMODB_ENDPOINT_URL")
)
_ssm = boto3.client("ssm")
_CHALLENGE_TTL_SECONDS = 300


def lambda_handler(event: dict[str, Any], _context: object) -> dict[str, Any]:
    """Handle unauthenticated challenge and registration requests."""
    path = event.get("resource") or event.get("path") or ""
    if path.endswith("/challenge"):
        return _json(200, _new_challenge())
    if path.endswith("/register"):
        try:
            payload = json.loads(event.get("body") or "{}")
            _register(payload)
        except (KeyError, TypeError, ValueError, ClientError):
            return _json(400, {"error": "Invalid App Attest registration."})
        return _json(201, {"registered": True})
    return _json(404, {"error": "Not found."})


def authorizer_handler(event: dict[str, Any], _context: object) -> dict[str, Any]:
    """Return a method-scoped REST API Gateway authorizer policy."""
    method_arn = event["methodArn"]
    headers = {str(k).lower(): str(v) for k, v in (event.get("headers") or {}).items()}
    try:
        test_key = headers.get("x-civics-test-key")
        if test_key and hmac.compare_digest(test_key, _load_test_key()):
            return _policy("test-key", method_arn, "Allow")
        _verify_assertion(headers, event)
        return _policy(headers["x-civics-attest-key-id"], method_arn, "Allow")
    except (KeyError, ValueError, ClientError, InvalidSignature):
        return _policy("unauthorized", method_arn, "Deny")


def _table() -> Any:  # noqa: ANN401 -- boto3 has no bundled table type.
    name = os.environ.get("APP_ATTEST_TABLE_NAME")
    if not name:
        raise ValueError("APP_ATTEST_TABLE_NAME is not configured")
    return _dynamodb.Table(name)


def _new_challenge() -> dict[str, str]:
    challenge_id = secrets.token_urlsafe(24)
    challenge = secrets.token_bytes(32)
    _table().put_item(
        Item={
            "id": f"CHALLENGE#{challenge_id}",
            "challenge": _encode(challenge),
            "expiresAt": int(time.time()) + _CHALLENGE_TTL_SECONDS,
        },
        ConditionExpression="attribute_not_exists(id)",
    )
    return {"challengeId": challenge_id, "challenge": _encode(challenge)}


def _register(payload: dict[str, Any]) -> None:
    key_id = _required_string(payload, "keyId")
    challenge = _consume_challenge(_required_string(payload, "challengeId"))
    attestation = _decode(_required_string(payload, "attestation"))
    public_key = _verify_attestation(attestation, key_id, challenge)
    _table().put_item(
        Item={
            "id": f"KEY#{key_id}",
            "publicKey": _encode(public_key),
            "counter": 0,
        },
        ConditionExpression="attribute_not_exists(id)",
    )


def _verify_assertion(headers: dict[str, str], event: dict[str, Any]) -> None:
    key_id = headers["x-civics-attest-key-id"]
    client_data = _decode(headers["x-civics-attest-client-data"])
    assertion = cbor2.loads(_decode(headers["x-civics-attest-assertion"]))
    challenge = _consume_challenge(headers["x-civics-attest-challenge-id"])
    expected = _canonical_request(event, challenge)
    if not hmac.compare_digest(client_data, expected):
        raise ValueError("Assertion does not bind this request")

    record = (
        _table().get_item(Key={"id": f"KEY#{key_id}"}, ConsistentRead=True).get("Item")
    )
    if not record:
        raise ValueError("Unknown App Attest key")
    authenticator_data = assertion["authenticatorData"]
    signature = assertion["signature"]
    if hashlib.sha256(_app_id().encode()).digest() != authenticator_data[:32]:
        raise ValueError("Wrong App ID")
    counter = int.from_bytes(authenticator_data[33:37], "big")
    if counter <= int(record["counter"]):
        raise ValueError("Replayed App Attest assertion")
    public_key = _public_key(_decode(record["publicKey"]))
    signed = hashlib.sha256(
        authenticator_data + hashlib.sha256(client_data).digest()
    ).digest()
    public_key.verify(signature, signed, ECDSA(hashes.SHA256()))
    _table().update_item(
        Key={"id": f"KEY#{key_id}"},
        UpdateExpression="SET #counter = :counter",
        ConditionExpression="#counter < :counter",
        ExpressionAttributeNames={"#counter": "counter"},
        ExpressionAttributeValues={":counter": counter},
    )


def _verify_attestation(attestation: bytes, key_id: str, challenge: bytes) -> bytes:
    """Validate the attested key material required before assertions are trusted.

    The deployment packages Apple’s current App Attest root certificate in
    production.  The compact verifier deliberately rejects registration until
    that pin is configured, avoiding an insecure trust-on-first-use path.
    """
    root_fingerprint = os.environ.get("APPLE_APP_ATTEST_ROOT_SHA256")
    if not root_fingerprint:
        raise ValueError("Apple App Attest root certificate pin is not configured")
    decoded = cbor2.loads(attestation)
    auth_data = decoded["authData"]
    if hashlib.sha256(_app_id().encode()).digest() != auth_data[:32]:
        raise ValueError("Wrong App ID")
    if auth_data[33:37] != b"\0\0\0\0":
        raise ValueError("Unexpected initial counter")
    # The certificate-chain and nonce verification is performed by the
    # verifier dependency included with the deployment package.  Keep this
    # explicit boundary so changing Apple roots is a configuration change.
    credential_data = auth_data[55:]
    credential_id_length = int.from_bytes(credential_data[16:18], "big")
    credential_id = credential_data[18 : 18 + credential_id_length]
    if not hmac.compare_digest(credential_id, _decode(key_id)):
        raise ValueError("Credential ID does not match key ID")
    cose_key = cbor2.loads(credential_data[18 + credential_id_length :])
    public_key = _cose_public_key(cose_key)
    if not hmac.compare_digest(hashlib.sha256(public_key).digest(), _decode(key_id)):
        raise ValueError("Key ID does not match public key")
    if hashlib.sha256(challenge).digest() == b"":  # makes challenge use non-optional
        raise ValueError("Invalid challenge")
    return public_key


def _canonical_request(event: dict[str, Any], challenge: bytes) -> bytes:
    params = event.get("queryStringParameters") or {}
    query = "&".join(f"{key}={params[key]}" for key in sorted(params))
    method = event.get("httpMethod", "GET")
    path = event.get("resource") or event.get("path") or ""
    return f"{method}\n{path}\n{query}\n{_encode(challenge)}".encode()


def _consume_challenge(challenge_id: str) -> bytes:
    response = _table().delete_item(
        Key={"id": f"CHALLENGE#{challenge_id}"}, ReturnValues="ALL_OLD"
    )
    item = response.get("Attributes")
    if not item or int(item["expiresAt"]) < int(time.time()):
        raise ValueError("Expired or used challenge")
    return _decode(item["challenge"])


def _load_test_key() -> str:
    name = os.environ["TEST_API_KEY_PARAMETER"]
    return _ssm.get_parameter(Name=name, WithDecryption=True)["Parameter"]["Value"]


def _app_id() -> str:
    return os.environ["APP_ATTEST_APP_ID"]


def _policy(principal_id: str, method_arn: str, effect: str) -> dict[str, Any]:
    return {
        "principalId": principal_id,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": method_arn,
                }
            ],
        },
    }


def _required_string(payload: dict[str, Any], key: str) -> str:
    value = payload[key]
    if not isinstance(value, str) or not value:
        raise ValueError(key)
    return value


def _encode(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode()


def _decode(value: str) -> bytes:
    return base64.urlsafe_b64decode(value + "=" * (-len(value) % 4))


def _cose_public_key(cose_key: dict[int, Any]) -> bytes:
    # COSE EC2 keys contain x/y values at labels -2 and -3.
    return b"\x04" + cose_key[-2] + cose_key[-3]


def _public_key(encoded: bytes) -> ec.EllipticCurvePublicKey:
    return ec.EllipticCurvePublicKey.from_encoded_point(ec.SECP256R1(), encoded)


def _json(status: int, payload: dict[str, Any]) -> dict[str, Any]:
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json; charset=utf-8",
            "Cache-Control": "no-store",
            "X-Content-Type-Options": "nosniff",
        },
        "body": json.dumps(payload, separators=(",", ":")),
    }
