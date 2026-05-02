#!/bin/sh
set -eu

cd /app

export PORT="${PORT:-8080}"

if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
    mkdir -p database
    touch database/database.sqlite
fi

php artisan migrate --force --no-interaction

exec php artisan serve --host=0.0.0.0 --port="$PORT"
