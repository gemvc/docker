# ============================================================================
# GEMVC Nginx Mac Base Image - Alpine Linux (Apple Silicon / Mac-friendly)
# Build this as: gemvc/nginx-mac:latest
# Usage: FROM gemvc/nginx-mac:latest
# ============================================================================

FROM php:8.4-fpm-alpine

LABEL maintainer="GEMVC Architect"
LABEL version="1.0-gemvc"

ENV APP_ENV=production
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apk add --no-cache \
    nginx \
    curl \
    libzip \
    icu-libs \
    shadow \
    bash \
    gzip \
    openssl \
    && mkdir -p /run/nginx

RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    libzip-dev \
    icu-dev \
    linux-headers \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql opcache zip intl \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN echo "opcache.enable=1" > /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "opcache.interned_strings_buffer=16" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "opcache.max_accelerated_files=20000" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "opcache.jit_buffer_size=100M" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "opcache.jit=tracing" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "upload_max_filesize=64M" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "post_max_size=64M" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "memory_limit=256M" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "expose_php=Off" >> /usr/local/etc/php/conf.d/gemvc.ini

COPY nginx.conf /etc/nginx/http.d/default.conf
COPY security.conf /etc/nginx/security.conf

WORKDIR /var/www/html

RUN echo "<?php echo 'GEMVC Nginx Mac Runtime is Ready!'; ?>" > /var/www/html/index.php

RUN sed -i 's/user nginx;/user www-data;/' /etc/nginx/nginx.conf \
    && usermod -u 82 www-data && groupmod -g 82 www-data www-data \
    && chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 750 {} \; \
    && find /var/www/html -type f -exec chmod 640 {} \;

EXPOSE 80

CMD ["/bin/sh", "-c", "php-fpm -D && nginx -g 'daemon off;' "]
