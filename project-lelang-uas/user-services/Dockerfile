FROM php:8.2-fpm

# Install dependencies sistem dan ekstensi PHP
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl

RUN docker-php-ext-install pdo_mysql mbstring

# Set working directory
WORKDIR /var/www

# Copy project
COPY . .

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-interaction --optimize-autoloader

# Expose port sesuai mapping docker-compose
EXPOSE 8000

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]