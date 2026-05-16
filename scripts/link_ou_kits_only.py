#!/usr/bin/env python3
"""Связать комплекты АРМ (ПК + все мониторы/ИБП из строки); досоздать отсутствующие дочерние записи."""
import os
import sys
from pathlib import Path

import psycopg2

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "scripts"))

from load_ou_main import (  # noqa: E402
    EXCEL_PATH,
    count_arm_monitors_in_source,
    link_arm_kits_existing,
)

path = os.environ.get("OU_MAIN_EXCEL", EXCEL_PATH)
if not Path(path).exists():
    print(f"Файл не найден: {path}")
    raise SystemExit(1)

conn = psycopg2.connect(
    host=os.environ.get("PGHOST", "localhost"),
    port=os.environ.get("PGPORT", "5432"),
    dbname=os.environ.get("PGDATABASE", "ias_vniic"),
    user=os.environ.get("PGUSER", "postgres"),
    password=os.environ.get("PGPASSWORD", "12345"),
)
conn.autocommit = False
cur = conn.cursor()
cur.execute("SET search_path TO tech_accounting")
cur.execute("SELECT id FROM dic_equipment_status WHERE status_code = 'in_use' LIMIT 1")
status_row = cur.fetchone()
if not status_row:
    print("В БД нет статуса in_use")
    raise SystemExit(1)
status_id = status_row[0]

errors = []
try:
    stats = link_arm_kits_existing(path, conn, cur, status_id, errors)
    conn.commit()
    cur.execute(
        "SELECT COUNT(*) FROM equipment_links WHERE link_type = 'monitor'"
    )
    mon_links = cur.fetchone()[0]
    expected = count_arm_monitors_in_source(path)
    print(f"Связей monitor создано/подтверждено: {stats['links']}; дочерних equipment создано: {stats['equipment_created']}")
    print(f"Всего связей monitor в БД: {mon_links}; мониторов в источнике (строки-ПК): {expected}")
    if errors:
        for e in errors:
            print(" ", e)
except Exception:
    conn.rollback()
    raise
finally:
    cur.close()
    conn.close()
