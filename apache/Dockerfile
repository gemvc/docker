# ============================================================================
# GEMVC Apache Base Image - Alpine Linux (MAXIMUM PERFORMANCE)
# Build this as: gemvc/apache:latest
# Usage: FROM gemvc/apache:latest
# ============================================================================

FROM php:8.4-fpm-alpine

# ============================================================================
# Layer 1: Install system dependencies and PHP extensions (optimized)
# ============================================================================
RUN apk add --no-cache \
    apache2 \
    apache2-proxy \
    curl \
    git \
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
    && \
    # Install build dependencies for PECL extensions
    apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    autoconf \
    g++ \
    make \
    && \
    # Install APCu for user data caching (maximum performance)
    pecl install apcu \
    && docker-php-ext-enable apcu \
    && \
    # Install Redis extension for caching and sessions
    pecl install redis \
    && docker-php-ext-enable redis \
    && \
    # Clean up build dependencies and dev packages
    apk del --purge .build-deps \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    oniguruma-dev \
    && rm -rf /var/cache/apk/* /tmp/* /usr/src/*

# ============================================================================
# Layer 2: Install Composer
# ============================================================================
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ============================================================================
# Layer 3: Configure Apache, PHP-FPM, OPcache, PHP, and logging (MAX PERFORMANCE)
# ============================================================================
RUN \
    # Configure Apache modules
    sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule deflate_module/LoadModule deflate_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule headers_module/LoadModule headers_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule proxy_module/LoadModule proxy_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule proxy_fcgi_module/LoadModule proxy_fcgi_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule expires_module/LoadModule expires_module/' /etc/apache2/httpd.conf \
    && echo "ServerName localhost" >> /etc/apache2/httpd.conf \
    && \
    # Apache MAXIMUM PERFORMANCE settings
    echo "# Apache Performance Tuning" >> /etc/apache2/httpd.conf \
    && echo "Timeout 30" >> /etc/apache2/httpd.conf \
    && echo "KeepAlive On" >> /etc/apache2/httpd.conf \
    && echo "MaxKeepAliveRequests 100" >> /etc/apache2/httpd.conf \
    && echo "KeepAliveTimeout 5" >> /etc/apache2/httpd.conf \
    && echo "MaxRequestWorkers 256" >> /etc/apache2/httpd.conf \
    && echo "ServerLimit 16" >> /etc/apache2/httpd.conf \
    && echo "MaxConnectionsPerChild 10000" >> /etc/apache2/httpd.conf \
    && \
    # Configure Apache virtual host with PHP-FPM
    echo '<VirtualHost *:80>' > /etc/apache2/conf.d/vhost.conf \
    && echo '    ServerName localhost' >> /etc/apache2/conf.d/vhost.conf \
    && echo '    DocumentRoot /var/www/html' >> /etc/apache2/conf.d/vhost.conf \
    && echo '    <Directory /var/www/html>' >> /etc/apache2/conf.d/vhost.conf \
    && echo '        Options -Indexes +FollowSymLinks' >> /etc/apache2/conf.d/vhost.conf \
    && echo '        AllowOverride All' >> /etc/apache2/conf.d/vhost.conf \
    && echo '        Require all granted' >> /etc/apache2/conf.d/vhost.conf \
    && echo '        DirectoryIndex index.php index.html' >> /etc/apache2/conf.d/vhost.conf \
    && echo '    </Directory>' >> /etc/apache2/conf.d/vhost.conf \
    && echo '    <FilesMatch \.php$>' >> /etc/apache2/conf.d/vhost.conf \
    && echo '        SetHandler "proxy:fcgi://127.0.0.1:9000"' >> /etc/apache2/conf.d/vhost.conf \
    && echo '    </FilesMatch>' >> /etc/apache2/conf.d/vhost.conf \
    && echo '</VirtualHost>' >> /etc/apache2/conf.d/vhost.conf \
    && \
    # Configure Apache logging
    echo 'ErrorLog /proc/self/fd/2' >> /etc/apache2/conf.d/vhost.conf \
    && echo 'CustomLog /proc/self/fd/1 combined' >> /etc/apache2/conf.d/vhost.conf \
    && echo 'LogLevel warn' >> /etc/apache2/conf.d/vhost.conf \
    && \
    # Configure Apache gzip compression
    echo "<IfModule mod_deflate.c>" > /etc/apache2/conf.d/deflate.conf \
    && echo "    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json application/xml" >> /etc/apache2/conf.d/deflate.conf \
    && echo "    SetOutputFilter DEFLATE" >> /etc/apache2/conf.d/deflate.conf \
    && echo "</IfModule>" >> /etc/apache2/conf.d/deflate.conf \
    && \
    # Configure Apache expires for static content caching
    echo "<IfModule mod_expires.c>" > /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresActive On" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType image/jpg \"access plus 1 year\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType image/jpeg \"access plus 1 year\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType image/gif \"access plus 1 year\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType image/png \"access plus 1 year\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType text/css \"access plus 1 month\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "    ExpiresByType application/javascript \"access plus 1 month\"" >> /etc/apache2/conf.d/expires.conf \
    && echo "</IfModule>" >> /etc/apache2/conf.d/expires.conf \
    && \
    # Fine-tune PHP-FPM settings for MAXIMUM performance
    sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/user = www-data/user = apache/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/group = www-data/group = apache/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm = dynamic/pm = dynamic/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.max_children = 5/pm.max_children = 50/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.start_servers = 2/pm.start_servers = 10/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 5/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 20/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/;pm.max_requests = 500/pm.max_requests = 1000/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/;pm.process_idle_timeout = 10s/pm.process_idle_timeout = 10s/' /usr/local/etc/php-fpm.d/www.conf \
    && \
    # Add MAXIMUM PERFORMANCE PHP-FPM settings
    echo "; Maximum Performance Optimizations" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.status_path = /fpm-status" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "ping.path = /fpm-ping" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.max_spawn_rate = 32" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "request_terminate_timeout = 180" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "request_slowlog_timeout = 5" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "slowlog = /proc/self/fd/2" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "catch_workers_output = yes" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "decorate_workers_output = no" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "rlimit_files = 65536" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "rlimit_core = 0" >> /usr/local/etc/php-fpm.d/www.conf \
    && \
    # Configure PHP-FPM logging
    sed -i 's|;php_admin_value[error_log] =|php_admin_value[error_log] = /proc/self/fd/2|' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's|;php_admin_flag[log_errors] =|php_admin_flag[log_errors] = on|' /usr/local/etc/php-fpm.d/www.conf \
    && \
    # Enable fastcgi_finish_request for non-blocking operations
    echo "; Enable fastcgi_finish_request for non-blocking operations" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "clear_env = no" >> /usr/local/etc/php-fpm.d/www.conf \
    && \
    # Configure OPcache for MAXIMUM performance
    echo "opcache.enable=1" > /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.enable_cli=0" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.interned_strings_buffer=32" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=20000" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.save_comments=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.fast_shutdown=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.revalidate_freq=0" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.optimization_level=0x7FFFBFFF" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.huge_code_pages=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && \
    # Configure APCu for user data caching (MAXIMUM performance)
    echo "apc.enabled=1" > /usr/local/etc/php/conf.d/apcu.ini \
    && echo "apc.shm_size=64M" >> /usr/local/etc/php/conf.d/apcu.ini \
    && echo "apc.ttl=3600" >> /usr/local/etc/php/conf.d/apcu.ini \
    && echo "apc.enable_cli=0" >> /usr/local/etc/php/conf.d/apcu.ini \
    && echo "apc.slam_defense=1" >> /usr/local/etc/php/conf.d/apcu.ini \
    && \
    # PHP Runtime MAXIMUM PERFORMANCE optimizations
    echo "realpath_cache_size=4096K" > /usr/local/etc/php/conf.d/performance.ini \
    && echo "realpath_cache_ttl=600" >> /usr/local/etc/php/conf.d/performance.ini \
    && echo "max_execution_time=180" >> /usr/local/etc/php/conf.d/performance.ini \
    && echo "max_input_time=180" >> /usr/local/etc/php/conf.d/performance.ini \
    && echo "memory_limit=256M" >> /usr/local/etc/php/conf.d/performance.ini \
    && echo "default_socket_timeout=60" >> /usr/local/etc/php/conf.d/performance.ini \
    && echo "zend.assertions=0" >> /usr/local/etc/php/conf.d/performance.ini \
    && echo "opcache.enable_file_override=1" >> /usr/local/etc/php/conf.d/performance.ini \
    && \
    # Create directories and set permissions
    mkdir -p /var/www/html /var/log/apache2 \
    && chown -R apache:apache /var/www/html /var/log/apache2

# ============================================================================
# Health check and monitoring
# ============================================================================
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/fpm-ping || exit 1

# Expose port 80
EXPOSE 80

# ============================================================================
# Start services with proper logging and system optimizations
# ============================================================================
CMD ["sh", "-c", "ulimit -n 65536 && php-fpm -D && sleep 2 && httpd -D FOREGROUND"]

