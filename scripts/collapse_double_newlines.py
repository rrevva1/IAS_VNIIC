# -*- coding: utf-8 -*-
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views"
FILES = [
    "users/index.php",
    "references/locations.php",
    "references/parts.php",
    "references/chars.php",
    "references/equipment-status.php",
    "references/task-status.php",
    "software/index.php",
    "user-equipment-cards/index.php",
    "audit/index.php",
    "tasks/index.php",
    "arm/index.php",
    "arm/create.php",
    "tasks/view.php",
    "users/arm_create.php",
]


def collapse(text):
    text = text.replace("\r", "")
    while "\n\n" in text:
        text = text.replace("\n\n", "\n")
    return text


def main():
    for rel in FILES:
        p = ROOT / rel
        if not p.exists():
            continue
        raw = p.read_text(encoding="utf-8")
        fixed = collapse(raw)
        if fixed != raw:
            p.write_text(fixed, encoding="utf-8", newline="\n")
            print("ok", rel)


if __name__ == "__main__":
    main()
