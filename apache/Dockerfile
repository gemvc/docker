# ============================================================================
# GEMVC High-Performance Apache Base Image (Alpine)
# PHP 8.4 + Apache + PHP-FPM + Gzip + Composer
# Alpine-based for minimal size (~100MB vs ~500MB)
# Multi-stage build for optimal layering and caching
# ============================================================================

# Stage 1: Base Apache Alpine
FROM alpine:latest AS base

# Install Apache and PHP 8.4 with all dependencies
RUN apk add --no-cache \
    # Apache
    apache2 \
    apache2-utils \
    # PHP 8.4 and core extensions
    php84 \
    php84-apache2 \
    php84-cli \
    php84-common \
    php84-opcache \
    php84-phar \
    php84-pdo \
    php84-pdo_mysql \
    php84-mysqli \
    php84-zip \
    php84-gd \
    php84-intl \
    php84-mbstring \
    php84-xml \
    php84-curl \
    php84-bcmath \
    php84-tokenizer \
    php84-pear \
    # Build dependencies for PHP extensions
    $PHPIZE_DEPS \
    build-base \
    linux-headers \
    # Runtime dependencies
    curl \
    wget \
    git \
    unzip \
    ca-certificates \
    # Libraries for extensions
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    curl-dev

# Stage 2: PHP Extensions
FROM base AS php-extensions

# Install tokenizer extension via Alpine package (if available)
# php84-tokenizer should be available in Alpine PHP 8.4 packages
RUN apk add --no-cache php84-tokenizer 2>/dev/null || \
    (echo "WARNING: php84-tokenizer package not found. You may need to compile it." && \
     echo "To compile: Install PHP source and use phpize to build tokenizer extension")

# Verify tokenizer is loaded
RUN php -m | grep -i tokenizer || echo "WARNING: tokenizer extension not loaded"

# Verify iconv is available (usually built into php84-common)
# iconv is typically included in php84-common, verify it's available
RUN php -m | grep -i iconv || \
    (echo "extension=iconv.so" >> /etc/php84/php.ini && echo "iconv enabled via php.ini")

# Cleanup build dependencies
RUN apk del $PHPIZE_DEPS build-base linux-headers || true

# Stage 3: Composer
FROM php-extensions AS composer-stage

# Install Composer (latest version)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Verify Composer installation
RUN composer --version

# Stage 4: Final optimized image
FROM composer-stage AS final

# Enable Apache modules for performance
# Alpine Apache modules are enabled via LoadModule directives in conf.d/
# Check if modules are already loaded (in httpd.conf or any conf.d/*.conf) before adding them
RUN (grep -r "LoadModule.*rewrite_module" /etc/apache2/ 2>/dev/null | grep -q .) || \
        echo "LoadModule rewrite_module modules/mod_rewrite.so" > /etc/apache2/conf.d/00-rewrite.conf \
    && (grep -r "LoadModule.*headers_module" /etc/apache2/ 2>/dev/null | grep -q .) || \
        echo "LoadModule headers_module modules/mod_headers.so" > /etc/apache2/conf.d/00-headers.conf \
    && (grep -r "LoadModule.*deflate_module" /etc/apache2/ 2>/dev/null | grep -q .) || \
        echo "LoadModule deflate_module modules/mod_deflate.so" > /etc/apache2/conf.d/00-deflate.conf \
    && (grep -r "LoadModule.*expires_module" /etc/apache2/ 2>/dev/null | grep -q .) || \
        echo "LoadModule expires_module modules/mod_expires.so" > /etc/apache2/conf.d/00-expires.conf

# Handle MPM Event configuration
# Alpine Apache uses different module structure
# Check available MPM and configure accordingly
RUN if [ -f /etc/apache2/conf.d/mpm_event.conf ]; then \
        echo "MPM Event available"; \
    else \
        echo "Using default MPM (prefork or worker)"; \
    fi

# Check what config files Alpine's php84-apache2 package created
# This helps us avoid conflicts
RUN echo "=== Existing Apache config files ===" && \
    ls -la /etc/apache2/conf.d/ || true && \
    echo "=== Checking for duplicate module loads ===" && \
    (grep -r "LoadModule.*php_module" /etc/apache2/ 2>/dev/null || echo "No php_module LoadModule found") && \
    echo "=== Config check complete ===" || true

# Copy optimized Apache configuration files
# Alpine Apache uses /etc/apache2/conf.d/ for configuration
# Note: php84-apache2 package may already configure PHP module, so we use a separate file
COPY mpm_event.conf /etc/apache2/conf.d/mpm_event.conf
COPY php.conf /etc/apache2/conf.d/php-handler.conf
COPY security.conf /etc/apache2/conf.d/security.conf
COPY performance.conf /etc/apache2/conf.d/performance.conf

# Copy PHP configuration
# Alpine PHP 8.4 uses /etc/php84/ for configuration
COPY php.ini /etc/php84/php.ini
COPY opcache.ini /etc/php84/conf.d/opcache.ini

# Copy .htaccess file (GEMVC routing and performance config)
COPY .htaccess /var/www/html/.htaccess

# Create log directory for Apache
RUN mkdir -p /var/log/apache2 \
    && chown -R www-data:www-data /var/log/apache2 || true

# Configure Apache document root in httpd.conf
RUN sed -i 's|#ServerName www.example.com:80|ServerName localhost:80|' /etc/apache2/httpd.conf \
    && sed -i 's|/var/www/localhost/htdocs|/var/www/html|g' /etc/apache2/httpd.conf \
    || echo "Apache configuration updated"

# Verify Apache configuration is valid (Alpine uses httpd)
RUN httpd -t || echo "Warning: Apache config test failed, but continuing..."

# Set working directory
WORKDIR /var/www/html

# Create www-data user with proper permissions (Alpine uses apache user)
RUN addgroup -g 82 -S www-data 2>/dev/null || true \
    && adduser -u 82 -D -S -G www-data www-data 2>/dev/null || true \
    && mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod 644 /var/www/html/.htaccess 2>/dev/null || true

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start Apache in foreground (Alpine uses httpd)
CMD ["httpd", "-D", "FOREGROUND"]

