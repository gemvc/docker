# ============================================================================
# GEMVC Apache Mac Base Image - Alpine Linux (Apple Silicon / Mac-friendly)
# Build:  docker build -t gemvc/apache-mac:latest .
# Usage:  FROM gemvc/apache-mac:latest  (no extra Apache config in app Dockerfile)
# ============================================================================

FROM php:8.4-fpm-alpine

# Install system dependencies and PHP extensions
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache \
    apache2 \
    apache2-proxy \
    curl \
    libpng \
    libjpeg-turbo \
    freetype \
    libzip \
    oniguruma \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    oniguruma-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    opcache \
    zip \
    && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    autoconf \
    g++ \
    make \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del --purge .build-deps \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    oniguruma-dev \
    && rm -rf /var/cache/apk/* /tmp/* /usr/src/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Apache vhost — file-based (do not build vhost with echo; easy to break </FilesMatch>)
COPY apache-vhost.conf /etc/apache2/conf.d/vhost.conf

# Apache modules, tuning, PHP-FPM, and PHP ini
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule deflate_module/LoadModule deflate_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule headers_module/LoadModule headers_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule proxy_module/LoadModule proxy_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule proxy_fcgi_module/LoadModule proxy_fcgi_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule expires_module/LoadModule expires_module/' /etc/apache2/httpd.conf \
    && echo "ServerName localhost" >> /etc/apache2/httpd.conf \
    && echo "Timeout 30" >> /etc/apache2/httpd.conf \
    && echo "KeepAlive On" >> /etc/apache2/httpd.conf \
    && echo "MaxKeepAliveRequests 100" >> /etc/apache2/httpd.conf \
    && echo "KeepAliveTimeout 5" >> /etc/apache2/httpd.conf \
    && echo "ServerLimit 16" >> /etc/apache2/httpd.conf \
    && echo "MaxRequestWorkers 16" >> /etc/apache2/httpd.conf \
    && echo "MaxConnectionsPerChild 10000" >> /etc/apache2/httpd.conf \
    && echo "<IfModule mod_deflate.c>" > /etc/apache2/conf.d/deflate.conf \
    && echo "    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json application/xml" >> /etc/apache2/conf.d/deflate.conf \
    && echo "    SetOutputFilter DEFLATE" >> /etc/apache2/conf.d/deflate.conf \
    && echo "</IfModule>" >> /etc/apache2/conf.d/deflate.conf \
    && echo "<IfModule mod_expires.c>" > /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresActive On" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType image/jpg \"access plus 1 year\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType image/jpeg \"access plus 1 year\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType image/gif \"access plus 1 year\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType image/png \"access plus 1 year\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType text/css \"access plus 1 month\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType application/javascript \"access plus 1 month\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "</IfModule>" >> /etc/apache2/conf.d/expires.conf \
    && sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/user = www-data/user = apache/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/group = www-data/group = apache/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.max_children = 5/pm.max_children = 50/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.start_servers = 2/pm.start_servers = 10/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 5/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 20/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/;pm.max_requests = 500/pm.max_requests = 1000/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/;pm.process_idle_timeout = 10s/pm.process_idle_timeout = 10s/' /usr/local/etc/php-fpm.d/www.conf \
    && echo "request_terminate_timeout = 180" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "catch_workers_output = yes" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "clear_env = no" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "opcache.enable=1" > /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.enable_cli=0" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.interned_strings_buffer=32" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=20000" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.revalidate_freq=0" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.save_comments=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.fast_shutdown=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "apc.enabled=1" > /usr/local/etc/php/conf.d/apcu.ini \
    && echo "apc.shm_size=64M" >> /usr/local/etc/php/conf.d/apcu.ini \
    && echo "apc.ttl=3600" >> /usr/local/etc/php/conf.d/apcu.ini \
    && echo "apc.enable_cli=0" >> /usr/local/etc/php/conf.d/apcu.ini \
    && echo "realpath_cache_size=4096K" > /usr/local/etc/php/conf.d/performance.ini \
    && echo "realpath_cache_ttl=600" >> /usr/local/etc/php/conf.d/performance.ini \
    && echo "max_execution_time=180" >> /usr/local/etc/php/conf.d/performance.ini \
    && echo "max_input_time=180" >> /usr/local/etc/php/conf.d/performance.ini \
    && echo "memory_limit=256M" >> /usr/local/etc/php/conf.d/performance.ini \
    && echo "default_socket_timeout=60" >> /usr/local/etc/php/conf.d/performance.ini \
    && mkdir -p /var/www/html /var/log/apache2 \
    && chown -R apache:apache /var/www/html /var/log/apache2 \
    && httpd -t

EXPOSE 80

CMD ["/bin/sh", "-c", "php-fpm -D && httpd -D FOREGROUND"]
