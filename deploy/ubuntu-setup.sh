#!/usr/bin/env bash
# Полная подготовка окружения ИАС на Ubuntu: PostgreSQL, PHP, Nginx, зависимости, БД из дампа.
# Запуск: sudo bash deploy/ubuntu-setup.sh
# Из корня репозитория (IAS_VNIIC), либо задайте IAS_REPO_ROOT.

set -euo pipefail

: "${IAS_REPO_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
APP="${IAS_REPO_ROOT}/ias_uch_vnii"
DB_DIR="${IAS_REPO_ROOT}/db"
: "${IAS_SQL_DUMP:=${DB_DIR}/tech.sql}"
: "${DB_NAME:=ias_vniic}"
: "${DB_USER:=ias_vniic}"
: "${DB_PASSWORD:=ias_vniic_local}"
: "${WEB_USER:=www-data}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Запустите от root: sudo bash $0" >&2
  exit 1
fi

if [[ ! -d "$APP" ]]; then
  echo "Не найден каталог приложения: $APP" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "==> Установка пакетов (PostgreSQL, Nginx, PHP)..."
apt-get update -qq
apt-get install -y -qq \
  postgresql postgresql-contrib \
  nginx \
  php-fpm php-cli php-pgsql php-mbstring php-xml php-curl php-gd php-zip php-intl php-bcmath \
  nodejs npm \
  curl unzip ca-certificates

if ! command -v composer >/dev/null 2>&1; then
  echo "==> Установка Composer..."
  apt-get install -y -qq composer
fi

PHP_VER="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')"
echo "==> Обнаружена версия PHP: ${PHP_VER}"

echo "==> Каталоги runtime и права..."
install -d -m 0775 -o "${WEB_USER}" -g "${WEB_USER}" "${APP}/runtime" "${APP}/runtime/logs"
install -d -m 0775 -o "${WEB_USER}" -g "${WEB_USER}" "${APP}/web/assets" "${APP}/web/uploads"
chmod +x "${APP}/yii" 2>/dev/null || true

echo "==> Composer (production, без dev-пакетов)..."
cd "$APP"
if [[ -f composer.phar ]]; then
  php composer.phar install --no-dev --no-interaction --optimize-autoloader
else
  composer install --no-dev --no-interaction --optimize-autoloader
fi

if [[ ! -d "${APP}/web/ag-grid-community" ]]; then
  echo "==> AG Grid Community в web/ag-grid-community (npm)..."
  AG_TMP="$(mktemp -d)"
  ( cd "$AG_TMP" && npm install ag-grid-community@32.3.3 --silent )
  rm -rf "${APP}/web/ag-grid-community"
  mv "${AG_TMP}/node_modules/ag-grid-community" "${APP}/web/ag-grid-community"
  rm -rf "$AG_TMP"
  chown -R "${WEB_USER}:${WEB_USER}" "${APP}/web/ag-grid-community"
fi

echo "==> PostgreSQL: пользователь и база..."
sudo -u postgres psql -v ON_ERROR_STOP=1 <<EOSQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${DB_USER}') THEN
    CREATE ROLE ${DB_USER} LOGIN PASSWORD '${DB_PASSWORD}';
  ELSE
    ALTER ROLE ${DB_USER} PASSWORD '${DB_PASSWORD}';
  END IF;
END
\$\$;
SELECT format('CREATE DATABASE %I OWNER %I', '${DB_NAME}', '${DB_USER}')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}')
\gexec
ALTER DATABASE ${DB_NAME} OWNER TO ${DB_USER};
EOSQL

if [[ ! -f "$IAS_SQL_DUMP" ]]; then
  echo "Файл дампа не найден: $IAS_SQL_DUMP" >&2
  echo "Укажите другой путь: IAS_SQL_DUMP=/path/to/dump.sql sudo -E bash $0" >&2
  exit 1
fi

echo "==> Восстановление дампа (может занять несколько минут)..."
export PGPASSWORD="${DB_PASSWORD}"
psql -h localhost -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 -f "$IAS_SQL_DUMP"
unset PGPASSWORD

FPM_POOL="/etc/php/${PHP_VER}/fpm/pool.d/ias_uch_vnii.conf"
echo "==> PHP-FPM pool: ${FPM_POOL}"
cat >"$FPM_POOL" <<EOF
[ias_uch_vnii]
user = ${WEB_USER}
group = ${WEB_USER}
listen = /run/php/php${PHP_VER}-fpm-ias.sock
listen.owner = ${WEB_USER}
listen.group = ${WEB_USER}
pm = dynamic
pm.max_children = 20
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
chdir = ${APP}
env[DB_HOST] = 127.0.0.1
env[DB_PORT] = 5432
env[DB_NAME] = ${DB_NAME}
env[DB_USER] = ${DB_USER}
env[DB_PASSWORD] = ${DB_PASSWORD}
env[YII_ENV] = prod
env[YII_DEBUG] = 0
EOF

echo "==> Nginx site..."
NGINX_SITE=/etc/nginx/sites-available/ias_uch_vnii.conf
cat >"$NGINX_SITE" <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root ${APP}/web;
    index index.php;
    charset utf-8;
    client_max_body_size 64M;
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }
    location ~ \\.php\$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php${PHP_VER}-fpm-ias.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
    location ~ /(runtime|config|vendor)/ {
        deny all;
    }
}
EOF
ln -sf "$NGINX_SITE" /etc/nginx/sites-enabled/ias_uch_vnii.conf
rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true

nginx -t
systemctl reload php${PHP_VER}-fpm
systemctl restart php${PHP_VER}-fpm
systemctl reload nginx

echo ""
echo "Готово."
echo "  Приложение: ${APP}/web"
echo "  БД: ${DB_NAME}, пользователь: ${DB_USER}"
echo "  Откройте в браузере: http://$(hostname -I | awk '{print $1}')/"
echo "  С другой машины в той же сети — тот же URL по IP этого сервера; при необходимости: sudo ufw allow 80/tcp"
echo "  Смените пароли БД и учёток приложения после первого входа."
