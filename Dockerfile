FROM node:24-bookworm-slim AS frontend

WORKDIR /app
COPY package.json package-lock.json .npmrc ./
RUN npm ci
COPY resources ./resources
COPY vite.config.js ./
RUN npm run build

FROM php:8.4-fpm

ENV SESSION_DRIVER=file

RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx git unzip libzip-dev libpq-dev \
 && docker-php-ext-install pdo_mysql pdo_pgsql zip bcmath opcache \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .
COPY --from=frontend /app/public/build ./public/build

RUN mkdir -p bootstrap/cache storage/app/private storage/app/public \
    storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs \
 && composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader \
 && chown -R www-data:www-data storage bootstrap/cache database

COPY docker/nginx.conf /etc/nginx/laravel.conf.template
COPY --chmod=755 docker/start.sh /usr/local/bin/start.sh

EXPOSE 10000

CMD ["/usr/local/bin/start.sh"]
