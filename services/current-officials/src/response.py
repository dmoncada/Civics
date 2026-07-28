from __future__ import annotations

from datetime import UTC, datetime
from typing import Any

from .jurisdictions import jurisdiction


def make_response(
    congressional: dict[str, Any],
    registry: dict[str, Any],
    now: datetime | None = None,
) -> dict[str, Any]:
    metadata = jurisdiction(congressional["jurisdiction"])
    if not metadata:
        raise ValueError(f"Unsupported jurisdiction: {congressional['jurisdiction']}")

    as_of = min(congressional["as_of"], registry["as_of"])
    current_time = now or datetime.now(UTC)
    freshness = (
        "fresh"
        if _parse_iso8601(congressional["expires_at"]) > current_time
        else "stale"
    )

    response: dict[str, Any] = {
        "jurisdiction": metadata,
        "senators": congressional["senators"] if metadata["has_senators"] else [],
        "national": registry["national"],
        "as_of": as_of,
        "freshness": freshness,
        "sources": [congressional["source"], *registry["sources"]],
    }
    response["representatives"] = [
        _representative(candidate) for candidate in congressional["representatives"]
    ]
    if governor := registry["governors"].get(metadata["code"]):
        response["governor"] = governor
    return response


def _representative(candidate: dict[str, Any]) -> dict[str, Any]:
    representative = candidate.copy()
    if "district" in representative:
        representative["district"] = int(representative["district"])
    return representative


def _parse_iso8601(value: str) -> datetime:
    return datetime.fromisoformat(value)
