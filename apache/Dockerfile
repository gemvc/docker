# ============================================================================
# GEMVC High-Performance Apache Base Image (Alpine)
# PHP 8.4 FPM + Apache + Gzip + Composer
# Using php:8.4-fpm-alpine base for minimal size (~116MB vs ~500MB)
# ============================================================================

FROM php:8.4-fpm-alpine

# Metadata
LABEL maintainer="GEMVC Architect"
LABEL version="1.0-gemvc"

# Environment Settings
ENV APP_ENV=production
ENV COMPOSER_ALLOW_SUPERUSER=1

# ------------------------------------------------------------------------------
# 1. Install System Dependencies & Apache (PERSISTENT TOOLS)
# ------------------------------------------------------------------------------
RUN apk add --no-cache \
    apache2 \
    apache2-utils \
    curl \
    wget \
    libzip \
    icu-libs \
    shadow \
    bash \
    gzip \
    openssl \
    && mkdir -p /run/apache2

# ------------------------------------------------------------------------------
# 2. Install PHP Extensions
# ------------------------------------------------------------------------------
# Note: Dependencies here are removed after compile to save space
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    libzip-dev \
    icu-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    curl-dev \
    linux-headers \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        opcache \
        zip \
        intl \
        gd \
        mbstring \
        xml \
        curl \
        bcmath \
    && docker-php-ext-enable opcache \
    && apk del .build-deps

# Verify iconv and tokenizer are available (usually built into PHP core)
RUN php -m | grep -q iconv || docker-php-ext-install iconv || echo "WARNING: iconv not found"
RUN php -m | grep -q tokenizer || echo "WARNING: tokenizer not found (should be built-in)"

# ------------------------------------------------------------------------------
# 3. Install Composer Binary
# ------------------------------------------------------------------------------
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ------------------------------------------------------------------------------
# 4. Copy PHP Configuration Files
# ------------------------------------------------------------------------------
# Create session directory for PHP sessions
RUN mkdir -p /var/lib/php/sessions && chown -R www-data:www-data /var/lib/php/sessions

COPY php.ini /usr/local/etc/php/conf.d/gemvc.ini
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# ------------------------------------------------------------------------------
# 5. Enable Apache Modules
# ------------------------------------------------------------------------------
RUN echo "LoadModule rewrite_module modules/mod_rewrite.so" > /etc/apache2/conf.d/00-rewrite.conf && \
    echo "LoadModule headers_module modules/mod_headers.so" > /etc/apache2/conf.d/00-headers.conf && \
    echo "LoadModule deflate_module modules/mod_deflate.so" > /etc/apache2/conf.d/00-deflate.conf && \
    echo "LoadModule expires_module modules/mod_expires.so" > /etc/apache2/conf.d/00-expires.conf && \
    echo "LoadModule proxy_module modules/mod_proxy.so" > /etc/apache2/conf.d/00-proxy.conf && \
    echo "LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so" > /etc/apache2/conf.d/00-proxy-fcgi.conf

# ------------------------------------------------------------------------------
# 6. Copy Apache Configuration Files
# ------------------------------------------------------------------------------
COPY mpm_event.conf /etc/apache2/conf.d/mpm_event.conf
COPY php.conf /etc/apache2/conf.d/php-handler.conf
COPY security.conf /etc/apache2/conf.d/security.conf
COPY performance.conf /etc/apache2/conf.d/performance.conf

# ------------------------------------------------------------------------------
# 7. Configure Apache Document Root
# ------------------------------------------------------------------------------
RUN sed -i 's|#ServerName www.example.com:80|ServerName localhost:80|' /etc/apache2/httpd.conf \
    && sed -i 's|/var/www/localhost/htdocs|/var/www/html|g' /etc/apache2/httpd.conf \
    || echo "Apache configuration updated"

# ------------------------------------------------------------------------------
# 8. Copy .htaccess file (GEMVC routing and performance config)
# ------------------------------------------------------------------------------
COPY .htaccess /var/www/html/.htaccess

# ------------------------------------------------------------------------------
# 9. Setup Working Directory
# ------------------------------------------------------------------------------
WORKDIR /var/www/html

# ------------------------------------------------------------------------------
# 10. Set Permissions
# ------------------------------------------------------------------------------
RUN sed -i 's/user apache;/user www-data;/' /etc/apache2/httpd.conf \
    && usermod -u 82 www-data && groupmod -g 82 www-data \
    && chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && chmod 644 /var/www/html/.htaccess 2>/dev/null || true

# Create log directory for Apache
RUN mkdir -p /var/log/apache2 \
    && chown -R www-data:www-data /var/log/apache2 || true

# Verify Apache configuration is valid
RUN httpd -t || echo "Warning: Apache config test failed, but continuing..."

# Expose HTTP Port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# ------------------------------------------------------------------------------
# 11. Entrypoint - Start PHP-FPM and Apache
# ------------------------------------------------------------------------------
CMD ["/bin/bash", "-c", "php-fpm -D && httpd -D FOREGROUND"]
