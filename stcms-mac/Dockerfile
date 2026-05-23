# Minimal GEMVC STCMS Mac Base Image
# Build this as: gemvc/stcms-mac:latest
# Usage: FROM gemvc/stcms-mac:latest

FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    unzip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install -j$(nproc) \
    zip \
    intl \
    mbstring \
    opcache

RUN pecl install apcu && docker-php-ext-enable apcu

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN a2enmod rewrite headers ssl \
    && echo "ServerTokens Prod" >> /etc/apache2/apache2.conf \
    && echo "ServerSignature Off" >> /etc/apache2/apache2.conf

RUN echo "memory_limit = 256M" > /usr/local/etc/php/conf.d/custom.ini \
    && echo "upload_max_filesize = 10M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "post_max_size = 10M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "opcache.revalidate_freq=2" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "apc.enabled=1" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "apc.shm_size=64M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "expose_php=Off" >> /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html

RUN composer init --no-interaction --name="stcms/app" --description="STCMS Application" \
    && composer require "gemvc/stcms:1.6.2" --no-interaction --optimize-autoloader

COPY --chown=www-data:www-data . .

RUN test -f .htaccess && test -f public/.htaccess && echo ".htaccess files verified" || (echo "ERROR: .htaccess files missing!" && exit 1)

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1
