#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/i-3d}"
cd "$APP_DIR"

if [[ ! -s .env.production ]] ||
   ! grep -Eq '^MYSQL_ROOT_PASSWORD=.{32,}$' .env.production ||
   ! grep -Eq '^JWT_SECRET=.{32,}$' .env.production ||
   ! grep -Eq '^MEILI_MASTER_KEY=.{32,}$' .env.production; then
  mysql_secret=$(openssl rand -hex 32)
  jwt_secret=$(openssl rand -hex 48)
  meili_secret=$(openssl rand -hex 32)

  umask 077
  printf 'DB_NAME=i3d\nMYSQL_ROOT_PASSWORD=%s\nJWT_SECRET=%s\nMEILI_MASTER_KEY=%s\nSMTP_HOST=\nSMTP_PORT=587\nSMTP_USER=\nSMTP_PASSWORD=\nSMTP_FROM=info@i-3d.com.tr\n' \
    "$mysql_secret" "$jwt_secret" "$meili_secret" > .env.production
fi

chmod 600 .env.production
mkdir -p data/uploads backups

docker compose --env-file .env.production -f docker-compose.prod.yml \
  up -d mysql redis meilisearch
