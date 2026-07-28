from __future__ import annotations

import os
from typing import Any

import boto3

_dynamodb = boto3.resource(
    "dynamodb", endpoint_url=os.environ.get("DYNAMODB_ENDPOINT_URL")
)


def get_congressional_record(
    table_name: str, jurisdiction: str
) -> dict[str, Any] | None:
    response = _dynamodb.Table(table_name).get_item(
        Key={"id": f"CONGRESSIONAL#{jurisdiction}"}, ConsistentRead=True
    )
    return response.get("Item")


def put_congressional_record(table_name: str, record: dict[str, Any]) -> None:
    _dynamodb.Table(table_name).put_item(
        Item={**record, "id": f"CONGRESSIONAL#{record['jurisdiction']}"}
    )
