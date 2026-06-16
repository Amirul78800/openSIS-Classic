# Gunakan base image PHP 8.2 dengan Apache
FROM php:8.2-apache

# Install system dependencies dan PHP extensions yang diperlukan
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libzip-dev \
    libpng-dev \
    libxml2-dev \
    && docker-php-ext-install \
    mysqli \
    gd \
    zip \
    mbstring \
    xml \
    simplexml \
    dom \
    fileinfo \
    iconv \
    curl \
    zlib \
    xmlreader \
    xmlwriter \
    ctype \
    && a2enmod rewrite

# Clone dari GitHub repo awak (ganti USERNAME dan REPO)
WORKDIR /var/www/html
RUN git clone https://github.com/Amirul78800/openSIS-Classic.git . \
    && rm -rf .git

# Beri permission untuk web installer tulis file konfigurasi
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port Apache
EXPOSE 80
