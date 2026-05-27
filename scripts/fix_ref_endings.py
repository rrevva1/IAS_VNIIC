# -*- coding: utf-8 -*-
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views" / "references"
FILES = ["parts.php", "chars.php", "equipment-status.php", "task-status.php", "software/index.php", "user-equipment-cards/index.php"]
IDS = {
    "parts.php": "agGridRefParts",
    "chars.php": "agGridRefChars",
    "equipment-status.php": "agGridRefEquipmentStatus",
    "task-status.php": "agGridRefTaskStatus",
}

END = (
    '            <motion class="ag-grid-loading__inner text-center">\n'
    '                <i class="glyphicon glyphicon-refresh glyphicon-spin"></i>\n'
    '                <p>{msg}</p>\n'
    '            </motion>\n'
    '        </motion>\n'
    '    </motion>\n'
    '</motion>\n'
).replace("motion", "v").replace("motion", "v")
END = END.replace("<v", "<div").replace("</v>", "</div>")


def fix_ref(path, cid, msg):
    t = path.read_text(encoding="utf-8").replace("\r", "")
    t = t.replace("<motion ", "<div ").replace("</motion>", "</div>")
    pat = rf'(<div id="{cid}"[^>]*>)\s*<div[^>]*>.*?</div>\s*(</motion>\s*)+'
    pat = pat.replace("</motion>", "</div>")
    end = END.format(msg=msg)
    if re.search(pat, t, re.S):
        t = re.sub(pat, rf"\1\n{end}", t, count=1, flags=re.S)
    path.write_text(t, encoding="utf-8", newline="\n")
    print("ok", path.name)


for name in ["parts.php", "chars.php", "equipment-status.php", "task-status.php"]:
    fix_ref(ROOT / name, IDS[name], "Загрузка справочника...")

# software + cards
for rel, cid, msg in [
    ("software/index.php", "agGridSoftwareContainer", "Загрузка таблицы ПО..."),
    ("user-equipment-cards/index.php", "agGridUserEquipmentCardsContainer", "Загрузка карточек..."),
]:
    p = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views" / rel
    fix_ref(p, cid, msg)
