import pytest

from src.refresh import _load_api_key, _official, _representative


def test_load_api_key_uses_local_environment_value(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("CONGRESS_API_KEY", "local-key")

    assert _load_api_key(None) == "local-key"


def test_load_api_key_requires_local_key_or_ssm_parameter(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.delenv("CONGRESS_API_KEY", raising=False)

    with pytest.raises(RuntimeError, match="CONGRESS_API_KEY"):
        _load_api_key(None)


@pytest.mark.parametrize("value", [None, 0, "0"])
def test_omits_missing_districts(value: object) -> None:
    member = {"name": "Example Member", "district": value}

    assert "district" not in _representative(member)


def test_retains_numbered_districts() -> None:
    representative = _representative({"name": "Example Member", "district": 10})

    assert representative["district"] == 10


def test_retains_congress_portrait_and_party() -> None:
    official = _official(
        {
            "name": "Example Member",
            "depiction": {"imageUrl": "https://example.gov/member.jpg"},
            "partyName": "Example Party",
        }
    )

    assert official["image_url"] == "https://example.gov/member.jpg"
    assert official["party"] == "Example Party"
