# GEMVC OpenSwoole Base Image
# This is the official base image for all GEMVC OpenSwoole applications
# Published to: gemvc/swoole:latest
# 
# Includes:
# - OpenSwoole 25.2 with PHP 8.4 on Alpine
# - PHP Extensions: pdo_mysql, pdo_pgsql, opcache, apcu
# - OPcache JIT enabled with optimized settings
# - APCu for user data caching
# - Composer pre-installed
# - Common utilities (curl)

FROM openswoole/openswoole:25.2-php8.4-alpine

LABEL maintainer="GEMVC Team" \
      org.opencontainers.image.title="GEMVC OpenSwoole Base Image" \
      org.opencontainers.image.description="Official base image for GEMVC Framework OpenSwoole applications" \
      org.opencontainers.image.version="5.2" \
      org.opencontainers.image.vendor="GEMVC" \
      org.opencontainers.image.url="https://www.gemvc.de" \
      org.opencontainers.image.documentation="https://gemvc.de/docs"

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    curl \
    libpq \
    libstdc++ \
    linux-headers \
    && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    postgresql-dev \
    mysql-dev \
    && docker-php-ext-install pdo_mysql pdo_pgsql opcache \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del .build-deps \
    && rm -rf /tmp/pear

# Configure OPcache and APCu for optimal performance
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.interned_strings_buffer=16'; \
    echo 'opcache.max_accelerated_files=20000'; \
    echo 'opcache.validate_timestamps=0'; \
    echo 'opcache.jit=tracing'; \
    echo 'opcache.jit_buffer_size=128M'; \
    echo 'apc.enable_cli=1'; \
    echo 'apc.shm_size=128M'; \
    } > /usr/local/etc/php/conf.d/gemvc-performance.ini

# Set working directory
WORKDIR /var/www/html

# Default user (can be overridden)
USER www-data

# Healthcheck (can be overridden in child images)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9501/ || exit 1
