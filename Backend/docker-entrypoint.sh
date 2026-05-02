#!/bin/sh
set -eu

cd /app

export PORT="${PORT:-8080}"

# Railway Postgres define DATABASE_URL; Laravel usa DB_URL na ligação pgsql.
if [ -n "${DATABASE_URL:-}" ] && [ -z "${DB_URL:-}" ]; then
  export DB_URL="$DATABASE_URL"
fi

# Evita SQLite efémero no container quando já existe Postgres (plugin Railway).
db_url="${DB_URL:-}"
if [ -n "$db_url" ]; then
  case "$db_url" in
    postgres://*|postgresql://*)
      if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ] || [ -z "${DB_CONNECTION:-}" ]; then
        export DB_CONNECTION=pgsql
      fi
      ;;
  esac
fi

if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
  mkdir -p database
  touch database/database.sqlite
fi

php artisan migrate --force --no-interaction

exec php artisan serve --host=0.0.0.0 --port="$PORT"
