#!/usr/bin/env bash
# Запуск приложения на двух портах для работы под двумя учётными записями одновременно.
# У каждого порта своя сессия (cookies): откройте в браузере оба адреса и войдите под разными пользователями.
#
# Использование: из каталога ias_uch_vnii выполнить:
#   ./scripts/serve-two-ports.sh
# или:
#   bash scripts/serve-two-ports.sh

set -e
cd "$(dirname "$0")/.."
PORT1="${PORT1:-8080}"
PORT2="${PORT2:-8081}"

cleanup() {
  echo ""
  echo "Остановка серверов..."
  kill $P1 $P2 2>/dev/null || true
  exit 0
}
trap cleanup SIGINT SIGTERM

echo "Запуск портала на портах $PORT1 и $PORT2..."
php yii serve --port="$PORT1" &
P1=$!
php yii serve --port="$PORT2" &
P2=$!

echo ""
echo "  Портал 1 (учётная 1):  http://localhost:$PORT1"
echo "  Портал 2 (учётная 2):  http://localhost:$PORT2"
echo ""
echo "Откройте оба адреса в браузере и войдите под разными пользователями. Остановка: Ctrl+C."
echo ""

wait
