# -*- coding: utf-8 -*-
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views"
T = lambda s: s  # tag helper placeholder
D, ED = "<" + "div", "</" + "div>"

PATCHES = [
    ("tasks/index.php", "tasks-index-page", "tasks-index-page ag-grid-page", "agGridTasksContainer"),
    ("users/index.php", "users-index-page", "users-index-page ag-grid-page", "agGridUsersContainer"),
    ("audit/index.php", "audit-index-page", "audit-index-page ag-grid-page", "agGridAuditContainer"),
    ("software/index.php", "software-index-page", "software-index-page ag-grid-page", "agGridSoftwareContainer"),
    (
        "user-equipment-cards/index.php",
        "user-equipment-cards-index-page",
        "user-equipment-cards-index-page ag-grid-page",
        "agGridUserEquipmentCardsContainer",
    ),
]

REF_FILES = [
    ("references/locations.php", "agGridRefLocations"),
    ("references/parts.php", "agGridRefParts"),
    ("references/chars.php", "agGridRefChars"),
    ("references/equipment-status.php", "agGridRefEquipmentStatus"),
    ("references/task-status.php", "agGridRefTaskStatus"),
]

LOADING = {
    "agGridTasksContainer": "Загрузка таблицы заявок...",
    "agGridUsersContainer": "Загрузка таблицы пользователей...",
    "agGridAuditContainer": "Загрузка журнала аудита...",
    "agGridSoftwareContainer": "Загрузка таблицы ПО...",
    "agGridUserEquipmentCardsContainer": "Загрузка карточек...",
    "agGridRefLocations": "Загрузка справочника...",
    "agGridRefParts": "Загрузка справочника...",
    "agGridRefChars": "Загрузка справочника...",
    "agGridRefEquipmentStatus": "Загрузка справочника...",
    "agGridRefTaskStatus": "Загрузка справочника...",
    "agGridStatisticsUserContainer": "Загрузка статистики...",
    "agGridStatisticsExecutorContainer": "Загрузка статистики...",
}


def fix_bad_tags(text):
    return text.replace("<motion ", D + " ").replace("</motion>", ED)


def add_page_class(text, old_cls, new_cls):
    if "ag-grid-page" in text:
        return text
    return text.replace(f'class="{old_cls}"', f'class="{new_cls}"', 1)


def loading_block(msg):
    return (
        f'{D} class="ag-grid-loading__inner text-center">\n'
        f'                <i class="glyphicon glyphicon-refresh glyphicon-spin"></i>\n'
        f"                <p>{msg}</p>\n"
        f"            {ED}"
    )


def patch_container(text, cid):
    text = fix_bad_tags(text)
    if f'id="{cid}"' not in text:
        return text

    text = re.sub(
        rf'(id="{re.escape(cid)}"\s+)class="[^"]*"',
        r'\1class="ag-theme-quartz ag-grid-unified ag-grid-loading"',
        text,
        count=1,
    )
    text = re.sub(rf'(id="{re.escape(cid)}"[^>]*)\s+style="[^"]*"', r"\1", text, count=1)

    before = text.split(f'id="{cid}"', 1)[0]
    if "ag-grid-card" not in before[-500:]:
        text = text.replace(
            f'{D} id="{cid}"',
            f'{D} class="ag-grid-card">{D} id="{cid}"',
            1,
        )

    inner = loading_block(LOADING.get(cid, "Загрузка..."))
    pat = rf'({D} id="{re.escape(cid)}"[^>]*>)\s*{D} class="(?:ag-grid-loading__inner\s+)?text-center">.*?</div>\s*'
    if re.search(pat, text, re.S):
        text = re.sub(pat, rf"\1\n            {inner}\n        ", text, count=1, flags=re.S)
    elif f'ag-grid-loading__inner' not in text[text.find(cid) : text.find(cid) + 600]:
        text = re.sub(
            rf'({D} id="{re.escape(cid)}"[^>]*>)',
            rf"\1\n            {inner}\n        ",
            text,
            count=1,
        )

    return close_card(text, cid)


def close_card(text, cid):
    idx = text.find(f'id="{cid}"')
    if idx < 0:
        return text
    sub = text[idx:]
    m = re.search(rf'{D} id="{re.escape(cid)}"[^>]*>', sub)
    if not m:
        return text
    pos = m.end()
    depth = 1
    i = pos
    while i < len(sub) and depth > 0:
        if sub[i : i + 4] == D:
            depth += 1
            i += 4
        elif sub[i : i + 6] == ED:
            depth -= 1
            if depth == 0:
                end = idx + i + 6
                tail = text[end : end + 24].lstrip()
                if not tail.startswith(ED):
                    text = text[:end] + f"\n    {ED}" + text[end:]
                break
            i += 6
        else:
            i += 1
    return text


def process(path, old_cls=None, new_cls=None, cid=None):
    p = ROOT / path
    t = fix_bad_tags(p.read_text(encoding="utf-8"))
    if old_cls and new_cls:
        t = add_page_class(t, old_cls, new_cls)
    if cid:
        t = patch_container(t, cid)
    p.write_text(t, encoding="utf-8")


def main():
    for rel, old_cls, new_cls, cid in PATCHES:
        process(rel, old_cls, new_cls, cid)
        print("ok", rel)

    for path, cid in REF_FILES:
        p = ROOT / path
        t = fix_bad_tags(p.read_text(encoding="utf-8"))
        if "ag-grid-page" not in t:
            t = t.replace('class="references-page"', 'class="references-page ag-grid-page"', 1)
        t = patch_container(t, cid)
        p.write_text(t, encoding="utf-8")
        print("refs", path)

    sp = ROOT / "tasks/statistics.php"
    if sp.exists():
        t = fix_bad_tags(sp.read_text(encoding="utf-8"))
        if "ag-grid-page" not in t:
            t = t.replace('class="statistics-page"', 'class="statistics-page ag-grid-page"', 1)
        for cid in ("agGridStatisticsUserContainer", "agGridStatisticsExecutorContainer"):
            t = patch_container(t, cid)
        sp.write_text(t, encoding="utf-8")
        print("ok statistics.php")


if __name__ == "__main__":
    main()
