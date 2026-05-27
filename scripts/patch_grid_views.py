# -*- coding: utf-8 -*-
from pathlib import Path
import re

VIEWS = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views"

def add_page_class(content, old_class, new_class):
    return content.replace(old_class, new_class, 1)

def wrap_grid(content, container_id, loading_html):
    pattern = (
        rf'(<div\s+id="{re.escape(container_id)}"\s+)class="ag-theme-quartz"([^>]*>)'
        rf'(?:\s+style="[^"]*")?'
        rf'(>.*?</div>\s*</motion>)'
    )
    # simpler: replace class on container
    content = re.sub(
        rf'(id="{re.escape(container_id)}"\s+)class="ag-theme-quartz"',
        r'\1class="ag-theme-quartz ag-grid-unified ag-grid-loading"',
        content,
        count=1,
    )
    # wrap with ag-grid-card if not already
    needle = f'id="{container_id}"'
    if 'ag-grid-card' not in content.split(needle)[0][-200:]:
        content = content.replace(
            f'<div id="{container_id}"',
            f'<div class="ag-grid-card"><div id="{container_id}"',
            1,
        )
        # close card before parent section ends - insert before next modal or before closing div of page
        idx = content.find(f'id="{container_id}"')
        close_idx = content.find('</div>', content.find('</motion>', idx) if '</motion>' in content[idx:idx+500] else idx)
        # find closing of grid container
        m = re.search(
            rf'<div id="{re.escape(container_id)}"[^>]*>.*?</div>\s*</div>',
            content[idx:],
            re.S,
        )
        if m:
            end = idx + m.end() - len('</div>')
            content = content[:end] + '</div>' + content[end:]
    return content

def patch_file(path, page_class_from, page_class_to, container_id):
    p = VIEWS / path
    if not p.exists():
        print("skip", path)
        return
    t = p.read_text(encoding="utf-8")
    t = add_page_class(t, page_class_from, page_class_to)
    t = re.sub(
        rf'(id="{re.escape(container_id)}"\s+)class="ag-theme-quartz"(?:\s+style="[^"]*")?',
        r'\1class="ag-theme-quartz ag-grid-unified ag-grid-loading"',
        t,
        count=1,
    )
    # remove inline height style on grid container
    t = re.sub(
        rf'(id="{re.escape(container_id)}"[^>]*)\s+style="[^"]*"',
        r'\1',
        t,
        count=1,
    )
    if f'<motion class="ag-grid-card">' not in t and 'ag-grid-card' not in t.split(container_id)[0][-300:]:
        t = t.replace(
            f'<div id="{container_id}"',
            f'<motion class="ag-grid-card"><motion id="{container_id}"',
            1,
        )
    t = t.replace("<motion", "<motion").replace("</motion>", "</motion>")
    p.write_text(t, encoding="utf-8")
    print("patched", path)

# fix motion in output - the script has a bug. rewrite without motion
