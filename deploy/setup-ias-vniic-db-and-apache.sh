#!/usr/bin/env bash
# Выполнить на сервере с Apache и PostgreSQL (кластер на порту 5433):
#   sudo bash deploy/setup-ias-vniic-db-and-apache.sh
#
# Делает: пароль postgres = 12345, БД ias_vniic из дампа, виртуальный хост Apache с SetEnv (порт БД 5433).

set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Запустите: sudo bash $0" >&2
  exit 1
fi

: "${IAS_REPO_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
: "${IAS_SQL_DUMP:=${IAS_REPO_ROOT}/db/tech.sql}"
PGPORT="${PGPORT:-5433}"
APP_ROOT="${APP_ROOT:-/var/www/html/ias_uch_vnii}"
WEB="${APP_ROOT}/web"

if [[ ! -f "$IAS_SQL_DUMP" ]]; then
  echo "Нет файла дампа: $IAS_SQL_DUMP" >&2
  exit 1
fi

export PGPORT

echo "==> Расширение PHP pdo_pgsql (иначе Yii: «could not find driver»)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq php-pgsql

echo "==> Пароль пользователя postgres -> 12345 (порт кластера ${PGPORT})"
sudo -u postgres psql -p "$PGPORT" -d postgres -v ON_ERROR_STOP=1 -c "ALTER USER postgres WITH PASSWORD '12345';"

echo "==> Пересоздание БД ias_vniic"
sudo -u postgres psql -p "$PGPORT" -d postgres -v ON_ERROR_STOP=1 <<'EOSQL'
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'ias_vniic' AND pid <> pg_backend_pid();
DROP DATABASE IF EXISTS ias_vniic WITH (FORCE);
CREATE DATABASE ias_vniic WITH ENCODING 'UTF8' TEMPLATE template0 OWNER postgres;
EOSQL

echo "==> Восстановление из дампа (долго при большом файле)..."
# Не использовать -f: пользователь postgres не имеет доступа к чужому $HOME.
# Поток с stdin открывается текущим процессом (root при sudo bash) до смены UID.
sudo -u postgres psql -p "$PGPORT" -d ias_vniic -v ON_ERROR_STOP=1 <"$IAS_SQL_DUMP"

echo "==> Права на runtime / uploads / assets"
install -d -m 0775 -o www-data -g www-data "${APP_ROOT}/runtime" "${APP_ROOT}/runtime/logs" "${WEB}/assets" "${WEB}/uploads"

echo "==> Apache: mod_rewrite и виртуальный хост"
a2enmod rewrite >/dev/null 2>&1 || true

cat >/etc/apache2/sites-available/ias_vniic.conf <<EOF
<VirtualHost *:80>
    ServerName ias_vniic.local
    ServerAdmin webmaster@localhost
    DocumentRoot ${WEB}

    SetEnv DB_HOST 127.0.0.1
    SetEnv DB_PORT ${PGPORT}
    SetEnv DB_NAME ias_vniic
    SetEnv DB_USER postgres
    SetEnv DB_PASSWORD 12345
    SetEnv YII_ENV prod
    SetEnv YII_DEBUG 0

    <Directory ${WEB}>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/ias_vniic_error.log
    CustomLog \${APACHE_LOG_DIR}/ias_vniic_access.log combined
</VirtualHost>
EOF

a2ensite ias_vniic.conf >/dev/null 2>&1 || true
# Иначе первым остаётся 000-default — по IP открывается «Apache2 Default Page», а не ИАС.
a2dissite 000-default.conf >/dev/null 2>&1 || a2dissite 000-default >/dev/null 2>&1 || true

apache2ctl configtest
systemctl reload apache2

echo ""
echo "Готово: БД ias_vniic, postgres/12345, Apache DocumentRoot ${WEB}"
echo "Откройте http://$(hostname -I | awk '{print $1}')/ (или ServerName в /etc/hosts)."
