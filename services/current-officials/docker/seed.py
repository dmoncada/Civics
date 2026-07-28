from __future__ import annotations

import os
import time
from typing import Any

import boto3
from botocore.exceptions import EndpointConnectionError

_MAX_ATTEMPTS = 30
_RETRY_DELAY_SECONDS = 1


def main() -> None:
    table_name = os.environ["CONGRESSIONAL_TABLE_NAME"]
    endpoint_url = os.environ["DYNAMODB_ENDPOINT_URL"]
    _create_table(endpoint_url, table_name)
    boto3.resource("dynamodb", endpoint_url=endpoint_url).Table(table_name).put_item(
        Item=_record()
    )
    print(f"Seeded {table_name} with Washington congressional data.")


def _create_table(endpoint_url: str, table_name: str) -> None:
    dynamodb = boto3.resource("dynamodb", endpoint_url=endpoint_url)
    for attempt in range(_MAX_ATTEMPTS):
        try:
            dynamodb.create_table(
                TableName=table_name,
                AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
                KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
                BillingMode="PAY_PER_REQUEST",
            )
        except dynamodb.meta.client.exceptions.ResourceInUseException:
            return
        except EndpointConnectionError:
            if attempt == _MAX_ATTEMPTS - 1:
                raise
            time.sleep(_RETRY_DELAY_SECONDS)
        else:
            return


def _record() -> dict[str, Any]:
    return {
        "id": "CONGRESSIONAL#WA",
        "jurisdiction": "WA",
        "senators": [
            {
                "displayName": "Example Senator",
                "acceptedAnswers": ["Example Senator", "Senator"],
            }
        ],
        "representatives": [
            {
                "displayName": "Example Representative",
                "acceptedAnswers": ["Example Representative", "Representative"],
                "district": 1,
            }
        ],
        "asOf": "2026-07-25T00:00:00.000Z",
        "refreshedAt": "2026-07-25T00:00:00.000Z",
        "expiresAt": "2099-01-01T00:00:00.000Z",
        "source": {"name": "Local seed", "url": "https://example.invalid/local-seed"},
    }


if __name__ == "__main__":
    main()
