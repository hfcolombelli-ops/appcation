# Laravel API — Railway / Docker
FROM php:8.4-cli-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libpq-dev libsqlite3-dev libicu-dev \
    && docker-php-ext-install -j"$(nproc)" intl opcache pdo_pgsql pdo_sqlite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY . .

RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts \
    && mkdir -p bootstrap/cache storage/framework/{sessions,views,cache} storage/logs database \
    && chmod -R ug+rwx storage bootstrap/cache \
    && chmod +x docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["./docker-entrypoint.sh"]
