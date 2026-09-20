# Step 1: Base Image (PHP-FPM base image, Apache bilkul nahi hai)
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

# Step 3: Container ke andar working directory set karna
WORKDIR /var/www/html

# Step 4: Local 'src/' folder se Laravel App ka Code copy karna
COPY src/ /var/www/html/

# Step 5: Storage aur Cache folders ki Permissions fix karna
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Step 6: FastCGI (PHP-FPM) Port Open karna
EXPOSE 9000

# Step 7: PHP-FPM Service start karna
CMD ["php-fpm"]