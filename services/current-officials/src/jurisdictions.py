from __future__ import annotations

from typing import TypedDict


class JurisdictionMetadata(TypedDict):
    code: str
    name: str
    has_senators: bool
    representative_kind: str


_STATES = (
    ("AL", "Alabama"),
    ("AK", "Alaska"),
    ("AZ", "Arizona"),
    ("AR", "Arkansas"),
    ("CA", "California"),
    ("CO", "Colorado"),
    ("CT", "Connecticut"),
    ("DE", "Delaware"),
    ("FL", "Florida"),
    ("GA", "Georgia"),
    ("HI", "Hawaii"),
    ("ID", "Idaho"),
    ("IL", "Illinois"),
    ("IN", "Indiana"),
    ("IA", "Iowa"),
    ("KS", "Kansas"),
    ("KY", "Kentucky"),
    ("LA", "Louisiana"),
    ("ME", "Maine"),
    ("MD", "Maryland"),
    ("MA", "Massachusetts"),
    ("MI", "Michigan"),
    ("MN", "Minnesota"),
    ("MS", "Mississippi"),
    ("MO", "Missouri"),
    ("MT", "Montana"),
    ("NE", "Nebraska"),
    ("NV", "Nevada"),
    ("NH", "New Hampshire"),
    ("NJ", "New Jersey"),
    ("NM", "New Mexico"),
    ("NY", "New York"),
    ("NC", "North Carolina"),
    ("ND", "North Dakota"),
    ("OH", "Ohio"),
    ("OK", "Oklahoma"),
    ("OR", "Oregon"),
    ("PA", "Pennsylvania"),
    ("RI", "Rhode Island"),
    ("SC", "South Carolina"),
    ("SD", "South Dakota"),
    ("TN", "Tennessee"),
    ("TX", "Texas"),
    ("UT", "Utah"),
    ("VT", "Vermont"),
    ("VA", "Virginia"),
    ("WA", "Washington"),
    ("WV", "West Virginia"),
    ("WI", "Wisconsin"),
    ("WY", "Wyoming"),
)

JURISDICTIONS: dict[str, JurisdictionMetadata] = {
    code: {
        "code": code,
        "name": name,
        "has_senators": True,
        "representative_kind": "representative",
    }
    for code, name in _STATES
}

JURISDICTIONS.update(
    {
        "DC": {
            "code": "DC",
            "name": "District of Columbia",
            "has_senators": False,
            "representative_kind": "delegate",
        },
        "AS": {
            "code": "AS",
            "name": "American Samoa",
            "has_senators": False,
            "representative_kind": "delegate",
        },
        "GU": {
            "code": "GU",
            "name": "Guam",
            "has_senators": False,
            "representative_kind": "delegate",
        },
        "MP": {
            "code": "MP",
            "name": "Northern Mariana Islands",
            "has_senators": False,
            "representative_kind": "delegate",
        },
        "PR": {
            "code": "PR",
            "name": "Puerto Rico",
            "has_senators": False,
            "representative_kind": "resident_commissioner",
        },
        "VI": {
            "code": "VI",
            "name": "U.S. Virgin Islands",
            "has_senators": False,
            "representative_kind": "delegate",
        },
    }
)


def jurisdiction(code: str) -> JurisdictionMetadata | None:
    return JURISDICTIONS.get(code.upper())
