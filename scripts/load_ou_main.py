#!/usr/bin/env python3
"""
Загрузка листов «АРМ» и «Принтеры» из файла «Основной Учет.xlsx» в БД ias_vniic, схема tech_accounting.
Парсинг строго по docs/import_ou/РЕГЛАМЕНТ_ПАРСИНГА.md.

- Лист АРМ: одна строка → запись equipment (ПК/только монитор) + отдельные записи equipment на каждый
  монитор по monitor_kit_entries (столбец «Монитор», см. РЕГЛАМЕНТ_ЗАГРУЗКИ_В_БД.md §5.1.5) и на каждый ИБП
  из «Другая техника» (МЦ.04-ups-XXX). Колонки ведомости бух. (19–21) не увеличивают число мониторов.
- Лист Принтеры: одна строка → одна запись equipment (Принтер/МФУ/Сканер);
  см. docs/import_ou/РЕГЛАМЕНТ_ПАРСИНГА.md п. 1.2.1–1.2.2 (бухведомость МЦ, без перезаписи ПК).
"""
import os
import re
from datetime import datetime
from pathlib import Path

try:
    import openpyxl
    import psycopg2
except ImportError as e:
    print("Требуются: pip install openpyxl psycopg2-binary")
    raise SystemExit(1) from e

PROJECT_ROOT = Path(__file__).resolve().parent.parent
EXCEL_PATH = os.environ.get("OU_MAIN_EXCEL", str(PROJECT_ROOT / "Основной Учет.xlsx"))
DB_HOST = os.environ.get("PGHOST", "localhost")
DB_PORT = os.environ.get("PGPORT", "5432")
DB_NAME = os.environ.get("PGDATABASE", "ias_vniic")
DB_USER = os.environ.get("PGUSER", "postgres")
DB_PASSWORD = os.environ.get("PGPASSWORD", "12345")
SCHEMA = "tech_accounting"
ORG_EQUIPMENT_TYPES = frozenset({"Принтер", "МФУ", "Сканер"})
# Хост комплекта АРМ (к нему относится столбец «Другая техника»).
KIT_HOST_EQUIPMENT_TYPES = frozenset(
    {"АРМ", "ПК", "Моноблок", "Системный блок", "Ноутбук", "Сервер"}
)
# Периферия и оргтехника: без «Другой техники» (ни в description, ни в UI).
NO_OTHER_TECH_TYPES = frozenset({"Монитор", "ИБП", "Принтер", "МФУ", "Сканер"})


def norm(v):
    if v is None:
        return None
    if isinstance(v, str):
        return v.strip() or None
    return v


def first_line_only(s):
    """При \\n в Пользователе брать первую строку."""
    if not s:
        return None
    s = str(s).strip()
    return s.split("\n")[0].strip() if "\n" in s else s


def inv_first_line(s):
    """Для № системн. блока при \\n — первая подстрока."""
    if not s:
        return None
    s = str(s).strip()
    return s.split("\n")[0].strip() if "\n" in s else s


def disk_value(s):
    """Диск: разделители \\n и запятая (полный файл); в БД одна запись — объединяем в один value_text."""
    if not s:
        return None
    s = str(s).strip()
    parts = re.split(r"[\n,]+", s)
    parts = [p.strip() for p in parts if p.strip()]
    return "; ".join(parts) if parts else None


def monitor_parts(s):
    """Монитор: список физических мониторов из ячейки (\\n, «;» / «; »). Запятая в «15,6"» не разделитель."""
    if not s:
        return []
    s = str(s).strip()
    if not s:
        return []
    if ";" in s:
        raw = re.split(r"\s*;\s*", s)
    else:
        raw = s.split("\n")
    parts = []
    for p in raw:
        p = p.strip()
        if not p or p.lower() == "моноблок":
            continue
        parts.append(p)
    return parts


def inv_parts(s):
    """Несколько учётных номеров в ячейке (\\n или «;»)."""
    if not s:
        return []
    s = str(s).strip()
    if not s:
        return []
    if ";" in s:
        raw = re.split(r"\s*;\s*", s)
    else:
        raw = s.split("\n")
    return [p.strip() for p in raw if p.strip()]


def is_placeholder_inv(s):
    """Повторяющиеся учётные пометки (не отдельный физический актив с уникальным номером)."""
    if s is None or not str(s).strip():
        return True
    t = str(s).strip().lower()
    if t in ("ниису", "электроника", "99036", "?", "мол"):
        return True
    if re.fullmatch(r"мц\.04", t):
        return True
    return False


def monitor_kit_entries(monitor_cell, inv_mon_cell=None, inv_statement_cell=None):
    """
    Физические мониторы комплекта строки-ПК — только из столбца «Монитор» (\\n, «;»)
    и при нескольких реальных «№ монитора» в одной ячейке.
    Колонка ведомости бух. инвентаризации — справочно (в part_char), не дублирует актив.
    Возвращает [(модель, исходный_учётный_номер|None), ...].
    """
    del inv_statement_cell  # не используется для числа активов
    models = monitor_parts(monitor_cell)
    if not models:
        return []
    if len(models) >= 2:
        invs = inv_parts(inv_mon_cell)
        return [
            (m, invs[i] if i < len(invs) and not is_placeholder_inv(invs[i]) else None)
            for i, m in enumerate(models)
        ]

    model = models[0]
    invs_real = [x for x in inv_parts(inv_mon_cell) if not is_placeholder_inv(x)]
    if len(invs_real) >= 2:
        return [(model, inv) for inv in invs_real]

    inv_primary = inv_first_line(inv_mon_cell)
    return [(model, inv_primary if not is_placeholder_inv(inv_primary) else None)]


def count_arm_monitors_in_source(path):
    """Число физических мониторов по листу АРМ (для контроля после загрузки)."""
    headers, rows = load_sheet(path, "АРМ")
    idx_monitor = get_col_index(headers, ["Монитор"])
    idx_sb = get_col_index(headers, ["Системный блок"])
    idx_inv_sb = get_col_index(headers, ["№ системн. блока"])
    total = 0
    for row in rows:
        def cell(i):
            return norm(row[i]) if i is not None and i < len(row) else None
        inv_sb = inv_first_line(cell(idx_inv_sb))
        has_sb = bool(inv_sb or cell(idx_sb))
        if has_sb:
            idx_inv_mon = get_col_index(headers, ["№ монитора"])
            total += len(
                monitor_kit_entries(
                    cell(idx_monitor),
                    cell(idx_inv_mon) if idx_inv_mon is not None else None,
                )
            )
    return total


def parse_date(val):
    """Год (int) -> 01.01.YYYY; DD.MM.YYYY -> date; иначе None."""
    if val is None:
        return None
    if isinstance(val, datetime):
        return val.date()
    if isinstance(val, (int, float)):
        y = int(val)
        if 1990 <= y <= 2030:
            return datetime(y, 1, 1).date()
        return None
    s = str(val).strip()
    if not s or "(" in s or "б/у" in s.lower():
        return None
    m = re.match(r"^(\d{1,2})\.(\d{1,2})\.(\d{4})$", s)
    if m:
        d, mo, y = int(m.group(1)), int(m.group(2)), int(m.group(3))
        try:
            return datetime(y, mo, d).date()
        except ValueError:
            return None
    if re.match(r"^\d{4}$", s):
        return datetime(int(s), 1, 1).date()
    return None


def location_name(val):
    """Помещение: число -> строка."""
    if val is None:
        return None
    if isinstance(val, (int, float)):
        return str(int(val))
    return str(val).strip() or None


def equipment_type_from_printer_name(name):
    """Тип актива по наименованию оргтехники (лист «Принтеры»)."""
    low = (name or "").lower()
    if "сканер" in low:
        return "Сканер"
    if "мфу" in low or "многофункциональн" in low:
        return "МФУ"
    return "Принтер"


def is_org_equipment_type(eq_type):
    return (eq_type or "").strip() in ORG_EQUIPMENT_TYPES


def is_kit_host_equipment_type(eq_type):
    """ПК/хост АРМ — единственный класс, к которому относится «Другая техника» из листа АРМ."""
    t = (eq_type or "").strip()
    if not t or t in NO_OTHER_TECH_TYPES:
        return False
    if t in KIT_HOST_EQUIPMENT_TYPES:
        return True
    low = t.lower()
    return "систем" in low or "ноутбук" in low or "моноблок" in low


def is_host_equipment_type(eq_type):
    """Запись, которую нельзя перезаписывать при импорте оргтехники по совпавшему инв. номеру."""
    return is_kit_host_equipment_type(eq_type)


def allows_other_tech_description(eq_type):
    return is_kit_host_equipment_type(eq_type)


def resolve_org_inventory(cur, inv, row_num, seen_inv):
    """Не перезаписывать ПК/монитор по совпавшему инв. номеру — выдать отдельный номер оргтехники."""
    if inv in seen_inv:
        inv = f"{inv}-строка{row_num}"
    cur.execute(
        "SELECT id, equipment_type FROM equipment WHERE inventory_number = %s",
        (inv,),
    )
    row = cur.fetchone()
    if row and is_host_equipment_type(row[1]):
        inv = f"{inv}-оргтехника-{row_num}"
    if inv in seen_inv:
        inv = f"{inv}-строка{row_num}"
    seen_inv.add(inv)
    return inv


def reset_org_equipment_side_effects(cur, equip_id):
    """У оргтехники не должно быть характеристик ПК, связей с АРМ и «Другой техники»."""
    cur.execute("DELETE FROM part_char_values WHERE equipment_id = %s", (equip_id,))
    cur.execute(
        "DELETE FROM equipment_links WHERE parent_equipment_id = %s OR child_equipment_id = %s",
        (equip_id, equip_id),
    )


def build_arm_other_tech_description(other_text, ups_list, note_text):
    """Остаток столбца «Другая техника» после извлечения ИБП + примечание строки-ПК."""
    desc_parts = []
    if other_text:
        remaining = other_text
        for u in ups_list:
            remaining = remaining.replace("ИБП " + u, "").strip()
        remaining = re.sub(r"\n+", " ", remaining).strip()
        if remaining:
            desc_parts.append(remaining)
    if note_text:
        desc_parts.append(note_text)
    return "; ".join(desc_parts) if desc_parts else None


def extract_ups_list(text):
    """Из «Другая техника» извлечь подстроки вида «ИБП <марка и модель>»; вернуть список name (без префикса ИБП )."""
    if not text:
        return []
    s = str(text).strip()
    result = []
    for part in re.split(r"[\n]+", s):
        part = part.strip()
        if part.startswith("ИБП "):
            result.append(part[4:].strip())
    return result


def load_sheet(path, sheet_name, max_rows=None):
    """Читает лист Excel; max_rows=None — все строки."""
    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
    ws = wb[sheet_name]
    headers = [str(c).strip() if c else "" for c in next(ws.iter_rows(min_row=1, max_row=1, values_only=True))]
    max_row = (2 + max_rows) if max_rows else ws.max_row
    rows = list(ws.iter_rows(min_row=2, max_row=max_row, values_only=True))
    wb.close()
    return headers, rows


def get_col_index(headers, names):
    for name in names:
        for i, h in enumerate(headers):
            if h and name in h:
                return i
    return None


def ensure_spr_parts_chars(cur, parts_chars):
    """parts_chars = {"ЦП": ["Модель"], "ОЗУ": ["Объём"], ...}. Возвращает dict part_name -> id, char_name -> id."""
    part_ids = {}
    char_ids = {}
    for part_name, char_list in parts_chars.items():
        cur.execute("SELECT id FROM spr_parts WHERE name = %s", (part_name,))
        r = cur.fetchone()
        if not r:
            cur.execute("INSERT INTO spr_parts (name) VALUES (%s) RETURNING id", (part_name,))
            part_ids[part_name] = cur.fetchone()[0]
        else:
            part_ids[part_name] = r[0]
        for char_name in char_list:
            cur.execute("SELECT id FROM spr_chars WHERE name = %s", (char_name,))
            r = cur.fetchone()
            if not r:
                cur.execute("INSERT INTO spr_chars (name) VALUES (%s) RETURNING id", (char_name,))
                char_ids[char_name] = cur.fetchone()[0]
            else:
                char_ids[char_name] = r[0]
    return part_ids, char_ids


def load_arm_sheet(conn, cur, path, status_id, role_id, parts, chars, seen_inv, mon_counter, ups_counter, errors):
    headers, rows = load_sheet(path, "АРМ")
    idx_user = get_col_index(headers, ["Пользователь"])
    idx_room = get_col_index(headers, ["Помещение"])
    idx_cpu = get_col_index(headers, ["ЦП"])
    idx_ram = get_col_index(headers, ["ОЗУ"])
    idx_disk = get_col_index(headers, ["Диск"])
    idx_sb = get_col_index(headers, ["Системный блок"])
    idx_inv_sb = get_col_index(headers, ["№ системн. блока"])
    idx_date_sb = get_col_index(headers, ["Дата закупки системного блока"])
    idx_monitor = get_col_index(headers, ["Монитор"])
    idx_inv_mon = get_col_index(headers, ["№ монитора"])
    idx_mon_inv_stmt = get_col_index(headers, ["Монитор в ведомости", "инвентаризации МЦ"])
    idx_date_mon = get_col_index(headers, ["Дата закупки монитора"])
    idx_hostname = get_col_index(headers, ["Имя"])
    idx_ip = get_col_index(headers, ["IP адрес"])
    idx_os = get_col_index(headers, ["ОС"])
    idx_av = get_col_index(headers, ["Антивирус"])
    idx_other = get_col_index(headers, ["Другая техника"])
    idx_note = get_col_index(headers, ["Примечание"])

    def get_or_create_location(name):
        name = location_name(name)
        if not name:
            return None
        cur.execute("SELECT id FROM locations WHERE name = %s", (name,))
        r = cur.fetchone()
        if r:
            return r[0]
        cur.execute(
            "INSERT INTO locations (name, location_type) VALUES (%s, 'кабинет') RETURNING id",
            (name,),
        )
        return cur.fetchone()[0]

    def get_or_create_user(full_name):
        full_name = first_line_only(full_name)
        if not full_name:
            return None
        cur.execute("SELECT id FROM users WHERE full_name = %s AND is_deleted = FALSE", (full_name,))
        r = cur.fetchone()
        if r:
            return r[0]
        cur.execute("INSERT INTO users (full_name) VALUES (%s) RETURNING id", (full_name,))
        uid = cur.fetchone()[0]
        if role_id:
            cur.execute(
                "INSERT INTO user_roles (user_id, role_id) VALUES (%s, %s) ON CONFLICT DO NOTHING",
                (uid, role_id),
            )
        return uid

    def add_pcv(equip_id, part_name, char_name, value):
        if value is None or not str(value).strip():
            return
        p_id = parts.get(part_name)
        c_id = chars.get(char_name)
        if p_id is None or c_id is None:
            return
        cur.execute(
            """INSERT INTO part_char_values (equipment_id, part_id, char_id, value_text)
               VALUES (%s, %s, %s, %s)
               ON CONFLICT (equipment_id, part_id, char_id) DO UPDATE SET value_text = EXCLUDED.value_text""",
            (equip_id, p_id, c_id, str(value).strip()[:5000]),
        )

    def insert_equipment(inv, name, eq_type, status_id, user_id, location_id, purchase_date, description):
        cur.execute(
            """INSERT INTO equipment (inventory_number, name, equipment_type, status_id, responsible_user_id, location_id, purchase_date, description)
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
               ON CONFLICT (inventory_number) DO UPDATE SET
                 name = EXCLUDED.name,
                 equipment_type = EXCLUDED.equipment_type,
                 status_id = EXCLUDED.status_id,
                 responsible_user_id = EXCLUDED.responsible_user_id,
                 location_id = EXCLUDED.location_id,
                 purchase_date = EXCLUDED.purchase_date,
                 description = EXCLUDED.description
               RETURNING id""",
            (
                inv,
                (name or inv)[:200],
                (eq_type or "Системный блок")[:100],
                status_id,
                user_id,
                location_id,
                purchase_date,
                description,
            ),
        )
        return cur.fetchone()[0]

    def equipment_id_by_inv(inv):
        cur.execute("SELECT id FROM equipment WHERE inventory_number = %s", (inv,))
        r = cur.fetchone()
        return r[0] if r else None

    def add_equipment_link(parent_id, child_id, link_type):
        if not parent_id or not child_id or parent_id == child_id:
            return
        cur.execute(
            """INSERT INTO equipment_links (parent_equipment_id, child_equipment_id, link_type)
               VALUES (%s, %s, %s)
               ON CONFLICT (parent_equipment_id, child_equipment_id, link_type) DO NOTHING""",
            (parent_id, child_id, link_type),
        )

    def is_host_equipment(eq_type):
        if not eq_type:
            return True
        t = str(eq_type).lower()
        return "систем" in t or "ноутбук" in t or "моноблок" in t

    loaded = 0
    links_created = 0
    for row_num, row in enumerate(rows, start=2):
        def cell(i):
            return norm(row[i]) if i is not None and i < len(row) else None

        inv_sb = inv_first_line(cell(idx_inv_sb))
        inv_mon = cell(idx_inv_mon)
        has_sb = bool(inv_sb or cell(idx_sb))
        if has_sb and not inv_sb:
            inv_sb = inv_mon or f"МЦ.04-ROW-{row_num}"
        if not has_sb:
            inv_sb = inv_first_line(inv_mon) if inv_mon else f"МЦ.04-MON-{row_num}"
        if not inv_sb:
            errors.append(f"АРМ строка {row_num}: нет инв. номера, пропуск")
            continue
        if inv_sb in seen_inv:
            inv_sb = f"{inv_sb}-строка{row_num}"
        seen_inv.add(inv_sb)

        loc_name = location_name(cell(idx_room))
        if not loc_name:
            errors.append(f"АРМ строка {row_num}: нет помещения, пропуск")
            continue
        location_id = get_or_create_location(loc_name)
        if not location_id:
            continue
        user_id = get_or_create_user(row[idx_user] if idx_user is not None else None)

        name_equip = cell(idx_sb)
        equipment_type = "Системный блок"
        if name_equip:
            if "моноблок" in name_equip.lower():
                equipment_type = "Моноблок"
            elif "ноутбук" in name_equip.lower():
                equipment_type = "Ноутбук"
        if not name_equip and cell(idx_monitor):
            name_equip = "; ".join(monitor_parts(cell(idx_monitor))) or "Монитор"
            equipment_type = "Монитор"
        if not name_equip:
            name_equip = inv_sb
        if name_equip and "\n" in name_equip:
            name_equip = name_equip.replace("\n", "; ")

        purchase_date = parse_date(cell(idx_date_sb)) if idx_date_sb is not None else None

        other_text = cell(idx_other)
        ups_list = extract_ups_list(other_text)
        description = None
        if allows_other_tech_description(equipment_type):
            description = build_arm_other_tech_description(
                other_text,
                ups_list,
                cell(idx_note) if idx_note is not None else None,
            )

        try:
            equip_id = insert_equipment(
                inv_sb, name_equip, equipment_type, status_id, user_id, location_id, purchase_date, description
            )
        except psycopg2.IntegrityError as e:
            errors.append(f"АРМ строка {row_num}: {e}")
            raise

        if idx_cpu is not None:
            add_pcv(equip_id, "ЦП", "Модель", cell(idx_cpu))
        if idx_ram is not None:
            add_pcv(equip_id, "ОЗУ", "Объём", cell(idx_ram))
        if idx_disk is not None:
            add_pcv(equip_id, "Накопитель", "Модель", disk_value(row[idx_disk]) if idx_disk < len(row) else None)
        if idx_monitor is not None and cell(idx_monitor):
            monitor_str = "; ".join(monitor_parts(cell(idx_monitor)))
            add_pcv(equip_id, "Монитор", "Модель", monitor_str)
        if idx_inv_mon is not None:
            add_pcv(equip_id, "Монитор", "№ монитора", cell(idx_inv_mon))
        if idx_hostname is not None:
            add_pcv(equip_id, "ПК", "Имя ПК", cell(idx_hostname))
        if idx_ip is not None:
            add_pcv(equip_id, "ПК", "IP адрес", cell(idx_ip))
        if idx_os is not None:
            add_pcv(equip_id, "ПК", "ОС", cell(idx_os))
        if idx_av is not None:
            add_pcv(equip_id, "ПК", "Антивирус", cell(idx_av))

        loaded += 1

        # Отдельные записи equipment на каждый монитор комплекта (есть СБ).
        kit_monitors = monitor_kit_entries(cell(idx_monitor), cell(idx_inv_mon)) if has_sb else []
        is_monoblock = name_equip and "моноблок" in name_equip.lower()
        for model, src_inv in kit_monitors:
            if not model or model.lower() == "моноблок":
                continue
            mon_counter[0] += 1
            inv_mon_eq = f"МЦ.04-mon-{mon_counter[0]}"
            if inv_mon_eq in seen_inv:
                inv_mon_eq = f"{inv_mon_eq}-строка{row_num}"
            seen_inv.add(inv_mon_eq)
            mon_desc = f"Исходный учётный номер: {src_inv}" if src_inv else None
            try:
                mon_id = insert_equipment(
                    inv_mon_eq, model, "Монитор", status_id, user_id, location_id, None, mon_desc
                )
                if has_sb and is_host_equipment(equipment_type):
                    add_equipment_link(equip_id, mon_id, "monitor")
                    links_created += 1
            except psycopg2.IntegrityError as e:
                errors.append(f"АРМ строка {row_num} монитор {model}: {e}")
                raise

        for ups_name in ups_list:
            ups_counter[0] += 1
            inv_ups = f"МЦ.04-ups-{ups_counter[0]}"
            if inv_ups in seen_inv:
                inv_ups = f"{inv_ups}-строка{row_num}"
            seen_inv.add(inv_ups)
            try:
                ups_id = insert_equipment(inv_ups, ups_name, "ИБП", status_id, user_id, location_id, None, None)
                if has_sb and is_host_equipment(equipment_type):
                    add_equipment_link(equip_id, ups_id, "ups")
                    links_created += 1
            except psycopg2.IntegrityError as e:
                errors.append(f"АРМ строка {row_num} ИБП {ups_name}: {e}")
                raise

    return loaded, links_created


def link_arm_kits_existing(path, conn, cur, status_id, errors):
    """Связать ПК с мониторами/ИБП по строкам АРМ; при отсутствии дочерней записи — создать equipment."""
    headers, rows = load_sheet(path, "АРМ")
    idx_user = get_col_index(headers, ["Пользователь"])
    idx_room = get_col_index(headers, ["Помещение"])
    idx_sb = get_col_index(headers, ["Системный блок"])
    idx_inv_sb = get_col_index(headers, ["№ системн. блока"])
    idx_monitor = get_col_index(headers, ["Монитор"])
    idx_other = get_col_index(headers, ["Другая техника"])
    idx_inv_mon = get_col_index(headers, ["№ монитора"])
    idx_mon_inv_stmt = get_col_index(headers, ["Монитор в ведомости", "инвентаризации МЦ"])

    seen_inv = set()
    mon_counter = [0]
    ups_counter = [0]
    stats = {"links": 0, "equipment_created": 0}

    def cell(row, i):
        return norm(row[i]) if i is not None and i < len(row) else None

    def equipment_id_by_inv(inv):
        cur.execute("SELECT id FROM equipment WHERE inventory_number = %s", (inv,))
        r = cur.fetchone()
        return r[0] if r else None

    def get_or_create_location(name):
        name = location_name(name)
        if not name:
            return None
        cur.execute("SELECT id FROM locations WHERE name = %s", (name,))
        r = cur.fetchone()
        if r:
            return r[0]
        cur.execute(
            "INSERT INTO locations (name, location_type) VALUES (%s, 'кабинет') RETURNING id",
            (name,),
        )
        return cur.fetchone()[0]

    def get_or_create_user(full_name):
        full_name = first_line_only(full_name)
        if not full_name:
            return None
        cur.execute("SELECT id FROM users WHERE full_name = %s AND is_deleted = FALSE", (full_name,))
        r = cur.fetchone()
        if r:
            return r[0]
        cur.execute("INSERT INTO users (full_name) VALUES (%s) RETURNING id", (full_name,))
        return cur.fetchone()[0]

    def upsert_child_equipment(inv, name, eq_type, user_id, location_id, description=None):
        existing_id = equipment_id_by_inv(inv)
        if existing_id:
            cur.execute(
                """UPDATE equipment SET name = %s, equipment_type = %s,
                   responsible_user_id = %s, location_id = %s, description = COALESCE(%s, description)
                   WHERE id = %s""",
                (
                    (name or inv)[:200],
                    (eq_type or "Монитор")[:100],
                    user_id,
                    location_id,
                    description,
                    existing_id,
                ),
            )
            return existing_id
        cur.execute(
            """INSERT INTO equipment (inventory_number, name, equipment_type, status_id, responsible_user_id, location_id, description)
               VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id""",
            (
                inv,
                (name or inv)[:200],
                (eq_type or "Монитор")[:100],
                status_id,
                user_id,
                location_id,
                description,
            ),
        )
        stats["equipment_created"] += 1
        return cur.fetchone()[0]

    def add_link(parent_id, child_id, link_type):
        if not parent_id or not child_id or parent_id == child_id:
            return
        cur.execute(
            """INSERT INTO equipment_links (parent_equipment_id, child_equipment_id, link_type)
               VALUES (%s, %s, %s)
               ON CONFLICT (parent_equipment_id, child_equipment_id, link_type) DO NOTHING""",
            (parent_id, child_id, link_type),
        )
        if cur.rowcount:
            stats["links"] += 1

    def is_host_equipment(eq_type):
        if not eq_type:
            return True
        t = str(eq_type).lower()
        return "систем" in t or "ноутбук" in t or "моноблок" in t

    for row_num, row in enumerate(rows, start=2):
        inv_sb = inv_first_line(cell(row, idx_inv_sb))
        inv_mon = cell(row, idx_inv_mon)
        has_sb = bool(inv_sb or cell(row, idx_sb))
        if has_sb and not inv_sb:
            inv_sb = inv_mon or f"МЦ.04-ROW-{row_num}"
        if not has_sb:
            continue
        if inv_sb in seen_inv:
            inv_sb = f"{inv_sb}-строка{row_num}"
        seen_inv.add(inv_sb)

        parent_id = equipment_id_by_inv(inv_sb)
        if not parent_id:
            errors.append(f"Связи строка {row_num}: не найден ПК {inv_sb}")
            continue

        loc_name = location_name(cell(row, idx_room))
        if not loc_name:
            errors.append(f"Связи строка {row_num}: нет помещения")
            continue
        location_id = get_or_create_location(loc_name)
        user_id = get_or_create_user(row[idx_user] if idx_user is not None else None)

        name_equip = cell(row, idx_sb)
        equipment_type = "Системный блок"
        if name_equip:
            if "моноблок" in name_equip.lower():
                equipment_type = "Моноблок"
            elif "ноутбук" in name_equip.lower():
                equipment_type = "Ноутбук"
        if not is_host_equipment(equipment_type):
            continue

        kit_monitors = monitor_kit_entries(cell(row, idx_monitor), cell(row, idx_inv_mon)) if has_sb else []
        for model, src_inv in kit_monitors:
            if not model or model.lower() == "моноблок":
                continue
            mon_counter[0] += 1
            inv_mon_eq = f"МЦ.04-mon-{mon_counter[0]}"
            if inv_mon_eq in seen_inv:
                inv_mon_eq = f"{inv_mon_eq}-строка{row_num}"
            seen_inv.add(inv_mon_eq)
            mon_desc = f"Исходный учётный номер: {src_inv}" if src_inv else None
            child_id = upsert_child_equipment(inv_mon_eq, model, "Монитор", user_id, location_id, mon_desc)
            if child_id:
                add_link(parent_id, child_id, "monitor")

        ups_list = extract_ups_list(cell(row, idx_other))
        for ups_name in ups_list:
            ups_counter[0] += 1
            inv_ups = f"МЦ.04-ups-{ups_counter[0]}"
            if inv_ups in seen_inv:
                inv_ups = f"{inv_ups}-строка{row_num}"
            seen_inv.add(inv_ups)
            child_id = upsert_child_equipment(inv_ups, ups_name, "ИБП", user_id, location_id)
            if child_id:
                add_link(parent_id, child_id, "ups")

    return stats


def load_printers_sheet(conn, cur, path, status_id, role_id, parts, chars, seen_inv, errors):
    headers, rows = load_sheet(path, "Принтеры")
    idx_user = get_col_index(headers, ["Пользователь"])
    idx_room = get_col_index(headers, ["Помещение"])
    idx_org = get_col_index(headers, ["Оргтехника"])
    idx_inv = get_col_index(headers, ["Инвент. № принтера", "Инвент. №"])
    idx_date = get_col_index(headers, ["Дата закупки"])
    idx_ip = get_col_index(headers, ["IP адрес"])
    idx_note = get_col_index(headers, ["Примечания"])
    idx_note2 = get_col_index(headers, ["Примечание"])

    def get_or_create_location(name):
        name = location_name(name)
        if not name:
            return None
        cur.execute("SELECT id FROM locations WHERE name = %s", (name,))
        r = cur.fetchone()
        if r:
            return r[0]
        cur.execute(
            "INSERT INTO locations (name, location_type) VALUES (%s, 'кабинет') RETURNING id",
            (name,),
        )
        return cur.fetchone()[0]

    def get_or_create_user(full_name):
        full_name = first_line_only(full_name)
        if not full_name:
            return None
        cur.execute("SELECT id FROM users WHERE full_name = %s AND is_deleted = FALSE", (full_name,))
        r = cur.fetchone()
        if r:
            return r[0]
        cur.execute("INSERT INTO users (full_name) VALUES (%s) RETURNING id", (full_name,))
        uid = cur.fetchone()[0]
        if role_id:
            cur.execute(
                "INSERT INTO user_roles (user_id, role_id) VALUES (%s, %s) ON CONFLICT DO NOTHING",
                (uid, role_id),
            )
        return uid

    loaded = 0
    for row_num, row in enumerate(rows, start=2):
        def cell(i):
            return norm(row[i]) if i is not None and i < len(row) else None

        name_equip = first_line_only(cell(idx_org)) if idx_org is not None else None
        if not name_equip:
            errors.append(f"Принтеры строка {row_num}: нет оргтехники, пропуск")
            continue
        inv = first_line_only(cell(idx_inv)) if idx_inv is not None else None
        if not inv:
            inv = f"МЦ.04-принтер-{row_num}"
        inv = resolve_org_inventory(cur, inv, row_num, seen_inv)

        eq_type = equipment_type_from_printer_name(name_equip)
        loc_name = location_name(cell(idx_room))
        if not loc_name:
            errors.append(f"Принтеры строка {row_num}: нет помещения, пропуск")
            continue
        location_id = get_or_create_location(loc_name)
        if not location_id:
            continue
        user_id = get_or_create_user(row[idx_user] if idx_user is not None else None)
        purchase_date = parse_date(cell(idx_date)) if idx_date is not None else None
        # Примечания листа «Принтеры» — не «Другая техника» АРМ; в гриде не показываются как ДР техника.
        desc_list = []
        if idx_note is not None and cell(idx_note):
            desc_list.append(first_line_only(cell(idx_note)))
        if idx_note2 is not None and idx_note2 != idx_note and cell(idx_note2):
            desc_list.append(cell(idx_note2))
        description = "; ".join(desc_list) if desc_list else None

        try:
            cur.execute(
                """INSERT INTO equipment (inventory_number, name, equipment_type, status_id, responsible_user_id, location_id, purchase_date, description)
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                   ON CONFLICT (inventory_number) DO UPDATE SET
                     name = EXCLUDED.name,
                     equipment_type = EXCLUDED.equipment_type,
                     status_id = EXCLUDED.status_id,
                     responsible_user_id = EXCLUDED.responsible_user_id,
                     location_id = EXCLUDED.location_id,
                     purchase_date = EXCLUDED.purchase_date,
                     description = EXCLUDED.description
                   RETURNING id""",
                (inv, name_equip[:200], eq_type[:100], status_id, user_id, location_id, purchase_date, description),
            )
            equip_id = cur.fetchone()[0]
        except psycopg2.IntegrityError as e:
            errors.append(f"Принтеры строка {row_num}: {e}")
            raise

        reset_org_equipment_side_effects(cur, equip_id)

        if idx_ip is not None and cell(idx_ip):
            p_id = parts.get("Принтер")
            c_id = chars.get("IP адрес")
            if p_id is not None and c_id is not None:
                cur.execute(
                    """INSERT INTO part_char_values (equipment_id, part_id, char_id, value_text)
                       VALUES (%s, %s, %s, %s)
                       ON CONFLICT (equipment_id, part_id, char_id) DO UPDATE SET value_text = EXCLUDED.value_text""",
                    (equip_id, p_id, c_id, str(cell(idx_ip)).strip()[:5000]),
                )
        loaded += 1
    return loaded


def main():
    path = Path(EXCEL_PATH)
    if not path.exists():
        print(f"Файл не найден: {EXCEL_PATH}")
        print("Укажите путь переменной OU_MAIN_EXCEL или поместите «Основной Учет.xlsx» в корень проекта.")
        raise SystemExit(1)

    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )
    conn.autocommit = False
    cur = conn.cursor()
    cur.execute(f"SET search_path TO {SCHEMA}")

    cur.execute("SELECT id FROM dic_equipment_status WHERE status_code = 'in_use' LIMIT 1")
    row = cur.fetchone()
    if not row:
        print("В БД нет статуса in_use. Выполните scripts/create_ias_vniic.sql")
        conn.rollback()
        conn.close()
        raise SystemExit(1)
    status_id = row[0]

    cur.execute("SELECT id FROM roles WHERE role_code = 'user' LIMIT 1")
    r = cur.fetchone()
    role_id = r[0] if r else None

    parts_chars = {
        "ЦП": ["Модель"],
        "ОЗУ": ["Объём"],
        "Накопитель": ["Модель"],
        "Монитор": ["Модель", "№ монитора"],
        "ПК": ["Имя ПК", "IP адрес", "ОС", "Антивирус"],
        "Принтер": ["IP адрес"],
    }
    flat_parts = list(parts_chars.keys())
    flat_chars = []
    for cl in parts_chars.values():
        flat_chars.extend(cl)
    parts, chars = {}, {}
    for p in flat_parts:
        cur.execute("SELECT id FROM spr_parts WHERE name = %s", (p,))
        r = cur.fetchone()
        if not r:
            cur.execute("INSERT INTO spr_parts (name) VALUES (%s) RETURNING id", (p,))
            parts[p] = cur.fetchone()[0]
        else:
            parts[p] = r[0]
    for c in set(flat_chars):
        cur.execute("SELECT id FROM spr_chars WHERE name = %s", (c,))
        r = cur.fetchone()
        if not r:
            cur.execute("INSERT INTO spr_chars (name) VALUES (%s) RETURNING id", (c,))
            chars[c] = cur.fetchone()[0]
        else:
            chars[c] = r[0]

    errors = []
    seen_inv = set()
    mon_counter = [0]
    ups_counter = [0]

    try:
        wb_check = openpyxl.load_workbook(str(path), read_only=True)
        sheetnames = wb_check.sheetnames
        wb_check.close()
        has_arm = "АРМ" in sheetnames
        has_printers = "Принтеры" in sheetnames

        if has_arm:
            loaded_arm, links_arm = load_arm_sheet(
                conn, cur, str(path), status_id, role_id, parts, chars, seen_inv, mon_counter, ups_counter, errors
            )
        else:
            loaded_arm, links_arm = 0, 0

        loaded_printers = (
            load_printers_sheet(conn, cur, str(path), status_id, role_id, parts, chars, seen_inv, errors)
            if has_printers
            else 0
        )

        if has_arm:
            repair_stats = link_arm_kits_existing(str(path), conn, cur, status_id, errors)
            expected_monitors = count_arm_monitors_in_source(str(path))
        else:
            repair_stats = {"links": 0, "equipment_created": 0}
            expected_monitors = 0

        conn.commit()
    except Exception:
        conn.rollback()
        cur.close()
        conn.close()
        raise

    cur.close()
    conn.close()

    print(f"Лист АРМ: загружено записей equipment (ПК/мониторы/ИБП): {loaded_arm}; дополнительно мониторов: {mon_counter[0]}, ИБП: {ups_counter[0]}")
    print(f"Лист АРМ: связей при импорте: {links_arm}; досоздано связей: {repair_stats['links']}, equipment: {repair_stats['equipment_created']}")
    print(f"Контроль: мониторов в источнике (строки-ПК): {expected_monitors}; создано записей мониторов при импорте: {mon_counter[0]}")
    print(f"Лист Принтеры: загружено записей equipment: {loaded_printers}")
    if errors:
        for e in errors:
            print("  ", e)


if __name__ == "__main__":
    main()
