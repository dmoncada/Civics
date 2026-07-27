import pytest

from src.refresh import _load_api_key


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
