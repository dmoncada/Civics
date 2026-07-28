from __future__ import annotations


def official_from_name(name: str) -> dict[str, object]:
    display_name = display_name_from_congress_name(name)
    parts = display_name.split()
    last_name = parts[-1] if parts else ""
    first_and_last = f"{parts[0]} {last_name}" if len(parts) > 1 else display_name
    accepted_answers = list(
        dict.fromkeys(
            answer for answer in (display_name, first_and_last, last_name) if answer
        )
    )
    return {"display_name": display_name, "accepted_answers": accepted_answers}


def display_name_from_congress_name(name: str) -> str:
    clean_name = " ".join(_remove_parentheticals(name).split())
    family, separator, given = clean_name.partition(",")
    return f"{given.strip()} {family.strip()}".strip() if separator else clean_name


def _remove_parentheticals(value: str) -> str:
    result: list[str] = []
    depth = 0
    for character in value:
        if character == "(":
            depth += 1
        elif character == ")" and depth:
            depth -= 1
        elif not depth:
            result.append(character)
    return "".join(result)
