# -*- coding: utf-8 -*-
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views"
OLD = (
    '        <div class="text-center text-muted p-4">Загрузка таблицы...</div>\n'
    "    </div>\n"
    "</div>\n"
)
NEW = (
    '            <motion class="ag-grid-loading__inner text-center">\n'
    '                <i class="glyphicon glyphicon-refresh glyphicon-spin"></i>\n'
    "                <p>{msg}</p>\n"
    "            </motion>\n"
    "        </motion>\n"
    "    </motion>\n"
    "</motion>\n"
).replace("motion", "X").replace("X", "div")

ITEMS = [
    ("references/parts.php", "Загрузка справочника..."),
    ("references/chars.php", "Загрузка справочника..."),
    ("references/equipment-status.php", "Загрузка справочника..."),
    ("references/task-status.php", "Загрузка справочника..."),
    ("user-equipment-cards/index.php", "Загрузка карточек..."),
]

for rel, msg in ITEMS:
    p = ROOT / rel
    t = p.read_text(encoding="utf-8").replace("\r", "")
    new = NEW.format(msg=msg)
    if OLD in t:
        t = t.replace(OLD, new, 1)
        p.write_text(t, encoding="utf-8", newline="\n")
        print("ok", rel)
    else:
        # cards variant
        old2 = (
            '        <div class="text-center p-4 text-muted">\n'
            "            <span class=\"glyphicon glyphicon-refresh glyphicon-spin\"></span>\n"
            "            <p>Загрузка карточек...</p>\n"
            "        </div>\n"
            "    </div>\n"
            "</motion>\n"
        ).replace("</motion>", "</motion>")
        old2 = old2.replace("</motion>", "</motion>").replace("</motion>", "</div>")
        if old2 in t:
            t = t.replace(old2, new, 1)
            p.write_text(t, encoding="utf-8", newline="\n")
            print("ok cards", rel)
        else:
            print("skip", rel)
