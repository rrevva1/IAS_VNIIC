#!/bin/sh
# Создание БД ias_vniic (lowercase — единый регистр на всех ОС) и восстановление из db/IAS_VNIIC_dump.sql (macOS/Linux)
# Требуется: PostgreSQL, psql в PATH. Пароль: переменная PGPASSWORD или .pgpass.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DUMPFILE="${SCRIPT_DIR}/../db/IAS_VNIIC_dump.sql"
PGHOST="${PGHOST:-localhost}"
PGUSER="${PGUSER:-postgres}"
DBNAME="ias_vniic"

echo "[1/2] Создание базы данных $DBNAME..."
psql -h "$PGHOST" -U "$PGUSER" -d postgres -c "CREATE DATABASE $DBNAME WITH ENCODING 'UTF8' OWNER $PGUSER TEMPLATE template0;" 2>/dev/null || true

echo "[2/2] Восстановление дампа в $DBNAME..."
if [ ! -f "$DUMPFILE" ]; then
  echo "Ошибка: файл дампа не найден: $DUMPFILE"
  exit 1
fi
psql -h "$PGHOST" -U "$PGUSER" -d "$DBNAME" -f "$DUMPFILE"
echo "Готово. БД $DBNAME восстановлена."
