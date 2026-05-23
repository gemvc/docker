# Minimal Production Dockerfile for STCMS
# Assets are pre-built before pushing to image
FROM php:8.2-apache

# Install system dependencies
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

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    zip \
    intl \
    mbstring \
    opcache

# Install APCu extension (for caching)
RUN pecl install apcu && docker-php-ext-enable apcu

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure Apache
RUN a2enmod rewrite headers ssl \
    && echo "ServerTokens Prod" >> /etc/apache2/apache2.conf \
    && echo "ServerSignature Off" >> /etc/apache2/apache2.conf

# Configure PHP for production
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

# Set working directory
WORKDIR /var/www/html

# Initialize Composer and install gemvc/stcms package directly
# Fixed to version 1.6.2 for reproducibility and predictability
# This makes the image independent - always includes gemvc/stcms 1.6.2
RUN composer init --no-interaction --name="stcms/app" --description="STCMS Application" \
    && composer require "gemvc/stcms:1.6.2" --no-interaction --optimize-autoloader

# Copy application files (including .htaccess files)
COPY --chown=www-data:www-data . .

# Verify .htaccess files are present
RUN test -f .htaccess && test -f public/.htaccess && echo ".htaccess files verified" || (echo "ERROR: .htaccess files missing!" && exit 1)

# Configure Apache document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Expose ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1
