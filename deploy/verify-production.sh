#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")/.."
compose=(docker compose --env-file .env.production -f docker-compose.prod.yml)

"${compose[@]}" ps
curl -fsS http://127.0.0.1:3200/ >/dev/null
curl -fsS http://127.0.0.1:3200/api/v1/health
echo

"${compose[@]}" exec -T mysql sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" -N -e "SELECT CONCAT(\"products=\", COUNT(*)) FROM products; SELECT CONCAT(\"categories=\", COUNT(*)) FROM categories; SELECT CONCAT(\"users=\", COUNT(*)) FROM users; SELECT CONCAT(\"admins=\", COUNT(*)) FROM admins; SELECT CONCAT(\"orders=\", COUNT(*)) FROM orders;"'
printf 'uploads=%s\n' "$(find data/uploads -type f | wc -l)"
