# Step 1: Base Image
FROM php:8.3-fpm

# Step 2: System Packages aur SQLite/PHP Extensions install karna
RUN apt-get update --fix-missing && apt-get install -y --no-install-recommends \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libsqlite3-dev \
    sqlite3 \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_sqlite pdo_mysql mbstring exif pcntl bcmath gd \
    && apt-get clean && rm -rf  /var/lib/apt/lists/* 

# Step 2.1: Composer install karna
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Step 3: Container ke andar working directory set karna
WORKDIR /var/www/html

# Step 4: Pehle Code copy karein (taake composer.json container mein aa jaye)
COPY src/ /var/www/html/

# Step 5: Code copy hone ke BAAD composer dependencies install karein
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Step 6: Storage aur Cache folders ki Permissions fix karna
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# SQLite file auto-create and permissions setup inside image
RUN touch /var/www/html/database/database.sqlite && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database

# Step 7: FastCGI (PHP-FPM) Port Open karna
EXPOSE 9000

# Step 8: PHP-FPM Service start karna
CMD ["php-fpm"]

