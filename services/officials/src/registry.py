from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def load_registry() -> dict[str, Any]:
    path = Path(__file__).resolve().parent.parent / "registry" / "officials.json"
    with path.open(encoding="utf-8") as registry_file:
        return json.load(registry_file)


REGISTRY = load_registry()
