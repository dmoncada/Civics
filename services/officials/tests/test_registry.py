import json
from pathlib import Path


def test_registry_officials_include_portraits_and_parties() -> None:
    path = Path(__file__).resolve().parent.parent / "registry" / "officials.json"
    registry = json.loads(path.read_text(encoding="utf-8"))

    officials = [*registry["national"].values(), *registry["governors"].values()]
    assert all(
        official.get("image_url", "").startswith("https://") for official in officials
    )
    assert "party" not in registry["national"]["chief_justice"]
    assert all(
        "party" in official
        for key, official in registry["national"].items()
        if key != "chief_justice"
    )
    assert all("party" in official for official in registry["governors"].values())
