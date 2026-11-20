#!/bin/sh
set -eu

if [ -z "${ASSET_URL:-}" ] && [ -n "${RENDER_EXTERNAL_URL:-}" ]; then
    export ASSET_URL="$RENDER_EXTERNAL_URL"
fi

port=${PORT:-10000}
case "$port" in
    *[!0-9]*) echo 'PORT must be numeric' >&2; exit 1 ;;
esac

sed "s/__PORT__/$port/g" /etc/nginx/laravel.conf.template > /etc/nginx/sites-available/default
nginx -t
php-fpm --daemonize
exec nginx -g 'daemon off;'
