# ==============================================================================
# GEMVC High-Performance Docker Image
# Base: Alpine Linux | PHP: 8.4 (Stable) | Web Server: Nginx
# ==============================================================================

FROM php:8.4-fpm-alpine

# Metadata
LABEL maintainer="GEMVC Architect"
LABEL version="1.0-gemvc"

# Environment Settings
ENV APP_ENV=production
ENV COMPOSER_ALLOW_SUPERUSER=1

# ------------------------------------------------------------------------------
# 1. Install System Dependencies & Nginx
# ------------------------------------------------------------------------------
# shadow: required for 'usermod'
# icu-libs: required for intl extension
# libzip: required for zip extension
RUN apk add --no-cache \
    nginx \
    curl \
    libzip \
    icu-libs \
    shadow \
    bash \
    && mkdir -p /run/nginx

# ------------------------------------------------------------------------------
# 2. Install PHP Extensions & Redis
# ------------------------------------------------------------------------------
# Strategy: Install build tools -> Compile extensions -> Remove build tools (Layer optimization)
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    libzip-dev \
    icu-dev \
    linux-headers \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql opcache zip intl \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# ------------------------------------------------------------------------------
# 3. Install Composer
# ------------------------------------------------------------------------------
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ------------------------------------------------------------------------------
# 4. Optimize PHP (Opcache & JIT & Limits)
# ------------------------------------------------------------------------------
# These settings are tuned for GEMVC production performance
RUN echo "opcache.enable=1" > /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "opcache.interned_strings_buffer=16" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "opcache.max_accelerated_files=20000" >> /usr/local/etc/php/conf.d/gemvc.ini \
    # Production Speed: Do not validate timestamps (Files are immutable)
    && echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/gemvc.ini \
    # Enable JIT (Tracing mode is standard for PHP 8.4)
    && echo "opcache.jit_buffer_size=100M" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "opcache.jit=tracing" >> /usr/local/etc/php/conf.d/gemvc.ini \
    # Increase Upload & Memory Limits
    && echo "upload_max_filesize=64M" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "post_max_size=64M" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "memory_limit=256M" >> /usr/local/etc/php/conf.d/gemvc.ini \
    && echo "expose_php=Off" >> /usr/local/etc/php/conf.d/gemvc.ini

# ------------------------------------------------------------------------------
# 5. Nginx Configuration
# ------------------------------------------------------------------------------
COPY nginx.conf /etc/nginx/http.d/default.conf
COPY security.conf /etc/nginx/security.conf

# ------------------------------------------------------------------------------
# 6. Copy Source Code & Install Dependencies
# ------------------------------------------------------------------------------
WORKDIR /var/www/html

# Copy composer files first to leverage Docker cache
COPY composer.json composer.lock* ./

# Install dependencies (Production mode: No Dev)
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Copy the rest of the application
COPY . .

# ------------------------------------------------------------------------------
# 7. Set Permissions
# ------------------------------------------------------------------------------
# www-data user ID in Alpine is typically 82
RUN sed -i 's/user nginx;/user www-data;/' /etc/nginx/nginx.conf \
    && usermod -u 82 www-data && groupmod -g 82 www-data \
    && chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 750 {} \; \
    && find /var/www/html -type f -exec chmod 640 {} \;

# Expose HTTP Port
EXPOSE 80

# ------------------------------------------------------------------------------
# 8. Entrypoint
# ------------------------------------------------------------------------------
# Start PHP-FPM in background (-D) and Nginx in foreground
CMD ["/bin/bash", "-c", "php-fpm -D && nginx -g 'daemon off;'"]