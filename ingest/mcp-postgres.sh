#!/usr/bin/env bash
set -a
source "$(dirname "$0")/.env"
set +a
exec npx -y @modelcontextprotocol/server-postgres "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_PORT}/${POSTGRES_DB}"
