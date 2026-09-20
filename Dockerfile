# Step 1: Base Image
FROM php:8.2-fpm

# Step 2: System Packages aur Laravel ke PHP Extensions install karna
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

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

# Step 7: FastCGI (PHP-FPM) Port Open karna
EXPOSE 9000

# Step 8: PHP-FPM Service start karna
CMD ["php-fpm"]