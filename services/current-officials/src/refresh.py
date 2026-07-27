from __future__ import annotations

import json
import os
from datetime import UTC, datetime, timedelta
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

import boto3

from .jurisdictions import JURISDICTIONS
from .officials import official_from_name
from .storage import put_congressional_record

_ssm = boto3.client("ssm")
_USER_AGENT = "Civics-current-officials/1.0"


def lambda_handler(_event: dict[str, Any], _context: object) -> None:
    table_name = os.environ.get("CONGRESSIONAL_TABLE_NAME")
    parameter_name = os.environ.get("CONGRESS_API_KEY_PARAMETER")
    if not table_name:
        raise RuntimeError("CONGRESSIONAL_TABLE_NAME is not configured")

    api_key = _load_api_key(parameter_name)
    failures: list[str] = []
    for code in JURISDICTIONS:
        try:
            put_congressional_record(table_name, _fetch_record(code, api_key))
        except Exception as error:  # noqa: BLE001 -- Refreshes remaining jurisdictions after a failure.
            failures.append(code)
            print(
                json.dumps(
                    {
                        "message": "Refresh failed",
                        "jurisdiction": code,
                        "error": str(error),
                    }
                )
            )

    if failures:
        raise RuntimeError(f"Refresh failed for: {', '.join(failures)}")


def _load_api_key(parameter_name: str | None) -> str:
    if api_key := os.environ.get("CONGRESS_API_KEY"):
        return api_key
    if not parameter_name:
        raise RuntimeError(
            "Configure CONGRESS_API_KEY locally or CONGRESS_API_KEY_PARAMETER in AWS"
        )
    value = _ssm.get_parameter(Name=parameter_name, WithDecryption=True)[
        "Parameter"
    ].get("Value")
    if not value:
        raise RuntimeError("Congress API key parameter is empty")
    return value


def _fetch_record(jurisdiction: str, api_key: str) -> dict[str, Any]:
    base_url = f"https://api.congress.gov/v3/member/{jurisdiction}"
    query = urlencode(
        {"format": "json", "currentMember": "true", "limit": "250", "api_key": api_key}
    )
    url = f"{base_url}?{query}"
    try:
        request = Request(url, headers={"User-Agent": _USER_AGENT})
        with urlopen(request, timeout=10) as response:
            payload = json.load(response)
    except HTTPError as error:
        raise RuntimeError(f"Congress.gov returned HTTP {error.code}") from error
    except URLError as error:
        raise RuntimeError("Congress.gov request failed") from error

    members = payload.get("members", [])
    senators = [
        official_from_name(member["name"]) for member in members if _is_senator(member)
    ]
    representatives = [
        {
            **official_from_name(member["name"]),
            "district": _district_value(member.get("district")),
        }
        for member in members
        if _is_representative(member)
    ]
    now = datetime.now(UTC)
    return {
        "jurisdiction": jurisdiction,
        "senators": senators,
        "representatives": representatives,
        "asOf": _iso8601(now),
        "refreshedAt": _iso8601(now),
        "expiresAt": _iso8601(now + timedelta(days=1)),
        "source": {"name": "Congress.gov", "url": base_url},
    }


def _is_senator(member: dict[str, Any]) -> bool:
    return "Senate" in _current_chambers(member)


def _is_representative(member: dict[str, Any]) -> bool:
    return bool({"House of Representatives", "House"} & set(_current_chambers(member)))


def _current_chambers(member: dict[str, Any]) -> list[str]:
    terms = member.get("terms", {}).get("item", [])
    return [
        term["chamber"]
        for term in terms
        if term.get("endYear") is None and isinstance(term.get("chamber"), str)
    ]


def _district_value(value: object) -> str:
    return "AL" if value in (None, 0, "0") else str(value)


def _iso8601(value: datetime) -> str:
    return value.isoformat(timespec="milliseconds").replace("+00:00", "Z")
