# -*- coding: utf-8 -*-
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views"
O, C = "<" + "div", "</" + "motion>".replace("motion", "div")


def read_p(path):
    return path.read_text(encoding="utf-8").replace("\r\n", "\n")


def write_p(path, text):
    path.write_text(text.replace("\n", "\r\n"), encoding="utf-8")


def loading_inner(msg):
    return (
        f'{O} class="ag-grid-loading__inner text-center">\n'
        f'                <i class="glyphicon glyphicon-refresh glyphicon-spin"></i>\n'
        f"                <p>{msg}</p>\n"
        f"            {C}"
    )


def close_card(text, cid):
    idx = text.find(f'id="{cid}"')
    if idx < 0:
        return text
    sub = text[idx:]
    m = re.search(rf'{O} id="{re.escape(cid)}"[^>]*>', sub)
    if not m:
        return text
    pos, depth, i = m.end(), 1, m.end()
    while i < len(sub) and depth > 0:
        if sub[i : i + 4] == O:
            depth += 1
            i += 4
        elif sub[i : i + 6] == C:
            depth -= 1
            if depth == 0:
                end = idx + i + 6
                if not text[end : end + 20].lstrip().startswith(C):
                    text = text[:end] + f"\n    {C}" + text[end:]
                break
            i += 6
        else:
            i += 1
    return text


def patch_grid_block(text, cid, msg, wrap_card=True):
    inner = loading_inner(msg)
    if wrap_card and "ag-grid-card" not in text.split(f'id="{cid}"')[0][-400:]:
        text = re.sub(
            rf'(\n\s*){O}\s*\n\s*id="{cid}"',
            rf'\1{O} class="ag-grid-card">\n        {O}\n        id="{cid}"',
            text,
            count=1,
        )
        text = re.sub(
            rf'(\n\s*){O} id="{cid}"',
            rf'\1{O} class="ag-grid-card">{O} id="{cid}"',
            text,
            count=1,
        )
    text = re.sub(
        rf'({O} id="{re.escape(cid)}"[^>]*>)\s*{O}[^>]*>.*?</motion>\s*({C})',
        rf"\1\n            {inner}\n        \2",
        text,
        count=1,
        flags=re.S,
    )
    text = text.replace("</motion>", C)
    return close_card(text, cid)


def main():
    # audit
    p = ROOT / "audit/index.php"
    t = read_p(p)
    t = t.replace('class="audit-index"', 'class="audit-index ag-grid-page"', 1)
    block = (
        f'    {O} class="ag-grid-card">\n'
        f'        {O} id="agGridAuditContainer" class="ag-theme-quartz ag-grid-unified ag-grid-loading">\n'
        f"            {loading_inner('Загрузка журнала аудита...')}\n"
        f"        {C}\n"
        f"    {C}"
    )
    t = re.sub(r'    <div class="ag-grid-card">.*?</div>\s*</div>', block, t, count=1, flags=re.S)
    write_p(p, t)
    print("audit")

    patches = [
        ("users/index.php", "users-index users-index-ag", "agGridUsersContainer", "Загрузка таблицы пользователей..."),
        ("software/index.php", "software-index", "agGridSoftwareContainer", "Загрузка таблицы ПО..."),
        ("user-equipment-cards/index.php", "user-equipment-cards-index", "agGridUserEquipmentCardsContainer", "Загрузка карточек..."),
    ]
    for rel, cls, cid, msg in patches:
        p = ROOT / rel
        t = read_p(p)
        if "ag-grid-page" not in t:
            t = t.replace(f'class="{cls}"', f'class="{cls} ag-grid-page"', 1)
        t = patch_grid_block(t, cid, msg)
        write_p(p, t)
        print(rel)

    refs = [
        ("references/locations.php", "references-locations", "agGridRefLocations"),
        ("references/parts.php", "references-parts", "agGridRefParts"),
        ("references/chars.php", "references-chars", "agGridRefChars"),
        ("references/equipment-status.php", "references-equipment-status", "agGridRefEquipmentStatus"),
        ("references/task-status.php", "references-task-status", "agGridRefTaskStatus"),
    ]
    for rel, cls, cid in refs:
        p = ROOT / rel
        t = read_p(p)
        if "ag-grid-page" not in t:
            t = t.replace(f'class="{cls}"', f'class="{cls} ag-grid-page"', 1)
        t = patch_grid_block(t, cid, "Загрузка справочника...")
        write_p(p, t)
        print(rel)

    p = ROOT / "arm/index.php"
    t = read_p(p)
    if "arm-grid" not in t:
        t = t.replace(
            "ag-theme-quartz ag-grid-unified ag-grid-loading",
            "ag-theme-quartz ag-grid-unified arm-grid ag-grid-loading",
            1,
        )
        write_p(p, t)
        print("arm")


def fix_closes_and_loading():
    items = [
        ("users/index.php", "agGridUsersContainer", "Загрузка таблицы пользователей..."),
        ("references/locations.php", "agGridRefLocations", "Загрузка справочника..."),
        ("references/parts.php", "agGridRefParts", "Загрузка справочника..."),
        ("references/chars.php", "agGridRefChars", "Загрузка справочника..."),
        ("references/equipment-status.php", "agGridRefEquipmentStatus", "Загрузка справочника..."),
        ("references/task-status.php", "agGridRefTaskStatus", "Загрузка справочника..."),
        ("software/index.php", "agGridSoftwareContainer", "Загрузка таблицы ПО..."),
        ("user-equipment-cards/index.php", "agGridUserEquipmentCardsContainer", "Загрузка карточек..."),
    ]
    for rel, cid, msg in items:
        p = ROOT / rel
        t = read_p(p)
        inner = loading_inner(msg)
        t = re.sub(
            rf"({O} id=\"{re.escape(cid)}\"[^>]*>)\s*{O}[^>]*>.*?</motion>\s*({C})",
            rf"\1\n            {inner}\n        \2",
            t,
            count=1,
            flags=re.S,
        )
        t = t.replace("</motion>", C)
        t = close_card(t, cid)
        write_p(p, t)
        print("fixed", rel)


if __name__ == "__main__":
    fix_closes_and_loading()
