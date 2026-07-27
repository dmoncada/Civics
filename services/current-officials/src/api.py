from __future__ import annotations

import json
import os
import re
from typing import Any

from .jurisdictions import jurisdiction
from .registry import REGISTRY
from .response import make_response
from .storage import get_congressional_record

_DISTRICT_PATTERN = re.compile(r"(?:[1-9][0-9]?|AL)$")


def lambda_handler(event: dict[str, Any], _context: object) -> dict[str, Any]:
    table_name = os.environ.get("CONGRESSIONAL_TABLE_NAME")
    if not table_name:
        raise RuntimeError("CONGRESSIONAL_TABLE_NAME is not configured")

    params = event.get("queryStringParameters") or {}
    code = str(params.get("jurisdiction", "")).strip().upper()
    district = params.get("district")
    district = str(district).strip() if district is not None else None
    if not jurisdiction(code) or (
        district is not None and not _DISTRICT_PATTERN.fullmatch(district)
    ):
        return _json(
            400,
            {
                "error": "Provide a supported two-letter jurisdiction and optional district."
            },
        )

    try:
        record = get_congressional_record(table_name, code)
        if not record:
            return _json(
                503,
                {"error": "Current officials are not available yet. Try again later."},
            )
        return _json(200, make_response(record, REGISTRY, district))
    except Exception as error:  # noqa: BLE001 -- Lambda returns a safe 503 for any dependency failure.
        print(
            json.dumps(
                {
                    "message": "Unable to retrieve current officials",
                    "error": type(error).__name__,
                }
            )
        )
        return _json(503, {"error": "Current officials are temporarily unavailable."})


def _json(status_code: int, body: dict[str, Any]) -> dict[str, Any]:
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json; charset=utf-8",
            "Cache-Control": "private, max-age=300",
            "X-Content-Type-Options": "nosniff",
        },
        "body": json.dumps(body, separators=(",", ":")),
    }
