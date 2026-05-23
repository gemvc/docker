# ============================================================================
# GEMVC OpenSwoole Mac Base Image - Alpine Linux (Apple Silicon / Mac-friendly)
# Build this as: gemvc/swoole-mac:latest
# Usage: FROM gemvc/swoole-mac:latest
# ============================================================================

FROM openswoole/openswoole:25.2-php8.4-alpine

LABEL maintainer="GEMVC Team" \
      org.opencontainers.image.title="GEMVC OpenSwoole Mac Base Image" \
      org.opencontainers.image.description="Mac-friendly variant of the GEMVC OpenSwoole base image" \
      org.opencontainers.image.version="5.2" \
      org.opencontainers.image.vendor="GEMVC" \
      org.opencontainers.image.url="https://www.gemvc.de" \
      org.opencontainers.image.documentation="https://gemvc.de/docs"

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

WORKDIR /var/www/html
USER www-data

# No healthcheck is defined in the base image on purpose.
# Each application image built FROM this base should define its own HEALTHCHECK.
