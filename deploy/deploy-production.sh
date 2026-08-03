#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/i-3d}"
cd "$APP_DIR"

git fetch origin main
git checkout main
git pull --ff-only origin main

docker compose --env-file .env.production -f docker-compose.prod.yml build --pull
docker compose --env-file .env.production -f docker-compose.prod.yml up -d --remove-orphans
docker compose --env-file .env.production -f docker-compose.prod.yml ps
