#!/usr/bin/env bash
set -euo pipefail

if [[ "${CONFIRM_REPLACE_DATABASE:-}" != "yes" ]]; then
  echo "Bu işlem canlı veritabanını dump ile değiştirir." >&2
  echo "Çalıştırmak için CONFIRM_REPLACE_DATABASE=yes ayarlayın." >&2
  exit 1
fi

APP_DIR="${APP_DIR:-/opt/i-3d}"
DUMP_FILE="${DUMP_FILE:-$APP_DIR/backups/i3d-local.sql}"
cd "$APP_DIR"

test -s "$DUMP_FILE"

until docker compose --env-file .env.production -f docker-compose.prod.yml \
  exec -T mysql sh -c 'mysqladmin ping -h 127.0.0.1 -uroot -p"$MYSQL_ROOT_PASSWORD" --silent'; do
  sleep 2
done

docker cp "$DUMP_FILE" i3d-mysql-1:/tmp/i3d-import.sql
docker compose --env-file .env.production -f docker-compose.prod.yml \
  exec -T mysql sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" < /tmp/i3d-import.sql'
docker compose --env-file .env.production -f docker-compose.prod.yml \
  exec -T mysql rm -f /tmp/i3d-import.sql

echo "Veritabanı import edildi."
