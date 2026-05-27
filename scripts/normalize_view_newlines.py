# -*- coding: utf-8 -*-
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views"


def normalize(text):
    text = text.replace("\r", "")
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text


def main():
    for php in ROOT.rglob("*.php"):
        raw = php.read_text(encoding="utf-8")
        fixed = normalize(raw)
        if fixed != raw:
            php.write_text(fixed, encoding="utf-8", newline="\n")
            print("normalized", php.relative_to(ROOT))


if __name__ == "__main__":
    main()
