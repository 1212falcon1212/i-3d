#!/usr/bin/env bash
# Şema migration'larını uygular. Compose'ta tek seferlik `migrate` servisi
# olarak çalışır ve biter.
#
# Uygulanan dosyalar `schema_migrations` tablosunda tutulur; her dosya bir kez
# çalışır, servis her açılışta yeniden koşsa bile.
#
# Bir seed'i yeniden uygulamak için (dosya idempotent olmak zorunda):
#   docker compose exec mysql mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" \
#     -e "DELETE FROM schema_migrations WHERE filename='033_i3d_products.sql';"
#   docker compose up migrate

set -euo pipefail

MIGRATIONS_DIR="${MIGRATIONS_DIR:-/migrations}"
DB_HOST="${DB_HOST:-mysql}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_NAME="${DB_NAME:?DB_NAME gerekli}"
export MYSQL_PWD="${DB_PASSWORD:-}"

MYSQL=(mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER"
  --default-character-set=utf8mb4 "$DB_NAME")

log() { printf '\033[1;34m[migrate]\033[0m %s\n' "$*"; }

"${MYSQL[@]}" -e "
CREATE TABLE IF NOT EXISTS schema_migrations (
  filename VARCHAR(255) PRIMARY KEY,
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;"

APPLIED=$("${MYSQL[@]}" -Nse "SELECT filename FROM schema_migrations;")

shopt -s nullglob
count=0
for f in "$MIGRATIONS_DIR"/*.sql; do
  name=$(basename "$f")
  if grep -qxF "$name" <<<"$APPLIED"; then
    continue
  fi
  log "applying $name"
  "${MYSQL[@]}" < "$f"
  "${MYSQL[@]}" -e "INSERT INTO schema_migrations (filename) VALUES ('$name');"
  count=$((count + 1))
done

log "tamam — bu çalıştırmada $count migration uygulandı"
