from __future__ import annotations

from typing import TypedDict


class JurisdictionMetadata(TypedDict):
    code: str
    name: str
    hasSenators: bool
    representativeKind: str


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
        "hasSenators": True,
        "representativeKind": "representative",
    }
    for code, name in _STATES
}

JURISDICTIONS.update(
    {
        "DC": {
            "code": "DC",
            "name": "District of Columbia",
            "hasSenators": False,
            "representativeKind": "delegate",
        },
        "AS": {
            "code": "AS",
            "name": "American Samoa",
            "hasSenators": False,
            "representativeKind": "delegate",
        },
        "GU": {
            "code": "GU",
            "name": "Guam",
            "hasSenators": False,
            "representativeKind": "delegate",
        },
        "MP": {
            "code": "MP",
            "name": "Northern Mariana Islands",
            "hasSenators": False,
            "representativeKind": "delegate",
        },
        "PR": {
            "code": "PR",
            "name": "Puerto Rico",
            "hasSenators": False,
            "representativeKind": "residentCommissioner",
        },
        "VI": {
            "code": "VI",
            "name": "U.S. Virgin Islands",
            "hasSenators": False,
            "representativeKind": "delegate",
        },
    }
)


def jurisdiction(code: str) -> JurisdictionMetadata | None:
    return JURISDICTIONS.get(code.upper())
