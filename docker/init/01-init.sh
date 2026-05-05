#!/bin/bash
set -e
# Убираем служебные psql-команды дампа и применяем его.
sed -e '/^\\restrict/d' -e '/^\\unrestrict/d' /docker-entrypoint-initdb.d/dump.sql.skip | psql -v ON_ERROR_STOP=1 -U postgres -d "${POSTGRES_DB:-ias_vniic}"
