#
# openSIS-Classic - all-in-one image (Apache + PHP 8.2 + MariaDB)
#
# Build (jalankan dari root repo openSIS-Classic):
#   docker build -t <docker-hub-username>/opensis-classic:9.3 .
#
FROM php:8.2-apache

ENV DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.title="openSIS Classic" \
      org.opencontainers.image.description="openSIS Classic Community Edition - all-in-one (Apache+PHP+MariaDB) image" \
      org.opencontainers.image.source="https://github.com/Amirul78800/openSIS-Classic"

# --- System packages: MariaDB server + library headers untuk PHP extensions ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        mariadb-server \
        mariadb-client \
        libzip-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libonig-dev \
        libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# --- PHP extensions yang diperlukan oleh openSIS + PhpSpreadsheet (vendored) ---
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        mysqli \
        gd \
        zip \
        mbstring \
        curl \
    && a2enmod rewrite

# --- php.ini tuning (bulk import, eksport Excel, borang besar seperti attendance) ---
RUN { \
        echo 'memory_limit = 512M'; \
        echo 'upload_max_filesize = 64M'; \
        echo 'post_max_size = 64M'; \
        echo 'max_execution_time = 300'; \
        echo 'max_input_vars = 3000'; \
        echo 'date.timezone = Asia/Kuala_Lumpur'; \
    } > /usr/local/etc/php/conf.d/opensis.ini

# --- Apache: benarkan .htaccess (AllowOverride) + senyapkan ServerName warning ---
RUN { \
        echo '<Directory /var/www/html>'; \
        echo '    AllowOverride All'; \
        echo '</Directory>'; \
    } > /etc/apache2/conf-available/opensis.conf \
    && a2enconf opensis \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# --- "Bake" source code app ke dalam image. Akan di-seed ke volume oleh entrypoint. ---
COPY --chown=www-data:www-data . /usr/src/opensis

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/var/www/html", "/var/lib/mysql"]
EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
