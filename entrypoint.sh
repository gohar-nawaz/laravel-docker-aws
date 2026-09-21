#!/bin/sh
set -e

# Local dev mein ./src bind-mount hoti hai, isliye har container start pe
# storage/cache/database ki ownership www-data ke liye fix karni padti hai.
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

if [ ! -f /var/www/html/database/database.sqlite ]; then
    touch /var/www/html/database/database.sqlite
fi
chown www-data:www-data /var/www/html/database /var/www/html/database/database.sqlite
chmod -R 775 /var/www/html/database

# Stale provider cache (dev/prod dependency mismatch se bachne ke liye) hata kar
# taaza discover karwana
rm -f /var/www/html/bootstrap/cache/packages.php /var/www/html/bootstrap/cache/services.php
php artisan package:discover --ansi || true

exec "$@"
