import json
from datetime import UTC, datetime
from decimal import Decimal

from src.response import make_response

CONGRESSIONAL = {
    "jurisdiction": "WA",
    "senators": [
        {"displayName": "Patty Murray", "acceptedAnswers": ["Patty Murray", "Murray"]}
    ],
    "representatives": [
        {
            "displayName": "Example Member",
            "acceptedAnswers": ["Example Member", "Member"],
            "district": "10",
        },
        {
            "displayName": "Another Member",
            "acceptedAnswers": ["Another Member", "Another"],
            "district": "7",
        },
    ],
    "asOf": "2026-07-24T00:00:00.000Z",
    "refreshedAt": "2026-07-24T00:00:00.000Z",
    "expiresAt": "2026-07-25T00:00:00.000Z",
    "source": {"name": "Congress.gov", "url": "https://api.congress.gov/v3/member/WA"},
}

REGISTRY = {
    "asOf": "2026-07-24T00:00:00.000Z",
    "sources": [],
    "national": {
        key: {"displayName": value, "acceptedAnswers": [value]}
        for key, value in {
            "president": "President",
            "vicePresident": "Vice President",
            "speaker": "Speaker",
            "chiefJustice": "Chief Justice",
        }.items()
    },
    "governors": {"WA": {"displayName": "Governor", "acceptedAnswers": ["Governor"]}},
}


def test_returns_all_representatives_with_integer_districts_and_fresh_data() -> None:
    response = make_response(
        CONGRESSIONAL,
        REGISTRY,
        now=datetime(2026, 7, 24, 12, tzinfo=UTC),
    )
    assert [member["district"] for member in response["representatives"]] == [10, 7]
    assert response["freshness"] == "fresh"


def test_converts_dynamodb_decimal_districts_to_json_numbers() -> None:
    congressional = {
        **CONGRESSIONAL,
        "representatives": [
            {**CONGRESSIONAL["representatives"][0], "district": Decimal(10)}
        ],
    }

    response = make_response(
        congressional, REGISTRY, now=datetime(2026, 7, 24, 12, tzinfo=UTC)
    )

    assert response["representatives"][0]["district"] == 10
    json.dumps(response)


def test_retains_a_representative_without_a_district() -> None:
    congressional = {
        **CONGRESSIONAL,
        "representatives": [
            {
                key: value
                for key, value in CONGRESSIONAL["representatives"][0].items()
                if key != "district"
            }
        ],
    }
    response = make_response(
        congressional, REGISTRY, datetime(2026, 7, 24, 12, tzinfo=UTC)
    )

    assert "district" not in response["representatives"][0]


def test_labels_expired_record_stale_while_retaining_answers() -> None:
    response = make_response(CONGRESSIONAL, REGISTRY, datetime(2026, 7, 26, tzinfo=UTC))
    assert response["senators"][0]["displayName"] == "Patty Murray"
    assert response["freshness"] == "stale"
