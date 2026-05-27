# -*- coding: utf-8 -*-
from pathlib import Path
import re

p = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views" / "tasks" / "statistics.php"
t = p.read_text(encoding="utf-8").replace("\r", "")
t = t.replace('class="tasks-statistics"', 'class="tasks-statistics ag-grid-page"', 1)

def wrap(cid, msg):
    global t
    pat = (
        rf'(\s*)<div\s+id="{cid}"\s+class="ag-theme-quartz ag-grid-unified ag-grid-loading"\s+'
        rf'data-url="([^"]*)"\s*></motion>'
    )
    pat = pat.replace("</motion>", "</div>")
    repl = (
        r'\1<div class="ag-grid-card">\n'
        rf'\1    <div id="{cid}" class="ag-theme-quartz ag-grid-unified ag-grid-loading"\n'
        rf'\1         data-url="\2">\n'
        rf'\1        <div class="ag-grid-loading__inner text-center">\n'
        rf'\1            <i class="glyphicon glyphicon-refresh glyphicon-spin"></i>\n'
        rf'\1            <p>{msg}</p>\n'
        rf'\1        </div>\n'
        rf'\1    </motion>\n'
        rf'\1</motion>'
    )
    repl = repl.replace("</motion>", "</div>")
    t2, n = re.subn(pat, repl, t, count=1)
    if n:
        t = t2
        print("wrapped", cid)
    else:
        print("miss", cid)

wrap("agGridStatisticsUserContainer", "Загрузка статистики...")
wrap("agGridStatisticsExecutorContainer", "Загрузка статистики...")
p.write_text(t, encoding="utf-8", newline="\n")
