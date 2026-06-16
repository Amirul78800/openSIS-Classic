FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libzip-dev \
    libpng-dev \
    libxml2-dev \
    --no-install-recommends \
    && docker-php-ext-install \
        mysqli \
        gd \
        zip \
        mbstring \
        xml \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone repo awak (ganti USERNAME/REPO)
WORKDIR /var/www/html
RUN git clone https://github.com/Amirul78800/openSIS-Classic.git . \
    && rm -rf .git \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80
