from datetime import UTC, datetime

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
        }
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


def test_returns_selected_representative_and_fresh_data() -> None:
    response = make_response(
        CONGRESSIONAL,
        REGISTRY,
        "10",
        datetime(2026, 7, 24, 12, tzinfo=UTC),
    )
    assert response["representative"]["displayName"] == "Example Member"
    assert response["freshness"] == "fresh"


def test_labels_expired_record_stale_while_retaining_answers() -> None:
    response = make_response(
        CONGRESSIONAL, REGISTRY, "10", datetime(2026, 7, 26, tzinfo=UTC)
    )
    assert response["senators"][0]["displayName"] == "Patty Murray"
    assert response["freshness"] == "stale"
