import json
from datetime import UTC, datetime
from decimal import Decimal

from src.api import _json
from src.response import make_response

CONGRESSIONAL = {
    "jurisdiction": "WA",
    "senators": [
        {
            "display_name": "Patty Murray",
            "accepted_answers": ["Patty Murray", "Murray"],
            "image_url": "https://example.gov/murray.jpg",
            "party": "Democratic",
        }
    ],
    "representatives": [
        {
            "display_name": "Example Member",
            "accepted_answers": ["Example Member", "Member"],
            "district": "10",
            "image_url": "https://example.gov/member.jpg",
            "party": "Example Party",
        },
        {
            "display_name": "Another Member",
            "accepted_answers": ["Another Member", "Another"],
            "district": "7",
        },
    ],
    "as_of": "2026-07-24T00:00:00.000Z",
    "refreshed_at": "2026-07-24T00:00:00.000Z",
    "expires_at": "2026-07-25T00:00:00.000Z",
    "source": {"name": "Congress.gov", "url": "https://api.congress.gov/v3/member/WA"},
}

REGISTRY = {
    "as_of": "2026-07-24T00:00:00.000Z",
    "sources": [],
    "national": {
        key: {"display_name": value, "accepted_answers": [value]}
        for key, value in {
            "president": "President",
            "vice_president": "Vice President",
            "speaker": "Speaker",
            "chief_justice": "Chief Justice",
        }.items()
    },
    "governors": {"WA": {"display_name": "Governor", "accepted_answers": ["Governor"]}},
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
    assert response["senators"][0]["display_name"] == "Patty Murray"
    assert response["freshness"] == "stale"


def test_retains_congressional_portraits_and_parties() -> None:
    response = make_response(CONGRESSIONAL, REGISTRY, datetime(2026, 7, 24, tzinfo=UTC))

    assert response["senators"][0]["image_url"] == "https://example.gov/murray.jpg"
    assert response["senators"][0]["party"] == "Democratic"
    assert (
        response["representatives"][0]["image_url"] == "https://example.gov/member.jpg"
    )
    assert response["representatives"][0]["party"] == "Example Party"


def test_json_response_uses_snake_case_for_all_nested_keys() -> None:
    response = make_response(CONGRESSIONAL, REGISTRY, datetime(2026, 7, 24, tzinfo=UTC))
    body = json.loads(_json(200, response)["body"])

    assert body["jurisdiction"] == {
        "code": "WA",
        "name": "Washington",
        "has_senators": True,
        "representative_kind": "representative",
    }
    assert body["as_of"] == "2026-07-24T00:00:00.000Z"
    assert body["senators"][0]["display_name"] == "Patty Murray"
    assert body["senators"][0]["accepted_answers"] == ["Patty Murray", "Murray"]
    assert body["senators"][0]["image_url"] == "https://example.gov/murray.jpg"
    assert body["national"]["vice_president"]["display_name"] == "Vice President"
