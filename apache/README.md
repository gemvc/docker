# GEMVC Apache Docker Image

## Overview
Version 1.2.0 based on php:8.4-fpm-alpine
GEMVC provides a pre-optimized Docker base image (`gemvc/apache:latest`) that includes PHP 8.4 FPM, Apache, and all performance optimizations. This allows developers to create simple, maintainable Dockerfiles with maximum performance out of the box.

## Quick Start

### For GEMVC Users (Recommended)

Create a simple `Dockerfile` in your project:

```dockerfile
FROM gemvc/apache:latest

WORKDIR /var/www/html

# Copy composer files first (for better caching)
COPY composer.json composer.lock* ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts \
    && composer clear-cache

# Copy application files
COPY . .

# Set proper permissions
RUN chown -R apache:apache /var/www/html \
    && chmod -R 755 /var/www/html \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && find /var/www/html -type d -exec chmod 755 {} \;
```

That's it! Your application is now running with maximum performance optimizations.

## What's Inside the Base Image

### Core Components

- **PHP 8.4 FPM Alpine** - Latest PHP with FastCGI Process Manager
- **Apache 2** - Web server configured with PHP-FPM proxy
- **Composer** - PHP dependency manager pre-installed

### PHP Extensions

- `pdo_mysql` - MySQL database connectivity
- `mbstring` - Multibyte string handling
- `exif` - Image metadata
- `pcntl` - Process control
- `bcmath` - Arbitrary precision mathematics
- `gd` - Image processing (with JPEG and FreeType support)
- `opcache` - Opcode cache (256MB, maximum optimization)
- `zip` - Archive handling
- `apcu` - User data caching (64MB)
- `redis` - Redis extension for caching and sessions

### Performance Optimizations

#### OPcache Configuration
- **Memory**: 256MB
- **Max Files**: 20,000
- **Interned Strings**: 32MB buffer
- **Optimization Level**: Maximum (0x7FFFBFFF)
- **Huge Code Pages**: Enabled
- **Timestamp Validation**: Disabled (production mode)

#### APCu Configuration
- **Shared Memory**: 64MB
- **TTL**: 3600 seconds (1 hour)
- **Slam Defense**: Enabled

#### PHP Runtime Optimizations
- **Realpath Cache**: 4MB (10min TTL) - Faster file lookups
- **Memory Limit**: 256M per process
- **Execution Time**: 180 seconds
- **Socket Timeout**: 60 seconds
- **Assertions**: Disabled (production)

#### PHP-FPM Pool Settings
- **Process Manager**: Dynamic
- **Max Children**: 50 workers
- **Start Servers**: 10
- **Min Spare**: 5
- **Max Spare**: 20
- **Max Requests**: 1000 (before recycling)
- **Spawn Rate**: 32 (prevents spawning storms)
- **Request Timeout**: 180 seconds
- **Slow Log**: 5 seconds

#### Apache Performance Tuning
- **KeepAlive**: On (connection reuse)
- **Max KeepAlive Requests**: 100
- **KeepAlive Timeout**: 5 seconds
- **Max Request Workers**: 256
- **Server Limit**: 16
- **Max Connections Per Child**: 10,000
- **Timeout**: 30 seconds

#### Compression & Caching
- **Gzip Compression**: Enabled for all text content
- **Static Content Caching**: mod_expires configured
  - Images: 1 year cache
  - CSS/JS: 1 month cache

### Monitoring & Health Checks

- **Health Check Endpoint**: `/fpm-ping`
- **Status Endpoint**: `/fpm-status`
- **Docker Health Check**: Automatic (30s interval)
- **Logging**: All logs to stdout/stderr (Docker-friendly)

## Usage Examples

### Basic Usage

```dockerfile
FROM gemvc/apache:latest

WORKDIR /var/www/html
COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
COPY . .
RUN chown -R apache:apache /var/www/html && chmod -R 755 /var/www/html
```

### With Custom PHP Configuration

```dockerfile
FROM gemvc/apache:latest

# Add custom PHP settings
RUN echo "upload_max_filesize = 10M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "post_max_size = 10M" >> /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html
COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
COPY . .
RUN chown -R apache:apache /var/www/html && chmod -R 755 /var/www/html
```

### With Custom PHP-FPM Settings

```dockerfile
FROM gemvc/apache:latest

# Override PHP-FPM pool settings for high-traffic apps
RUN sed -i 's/pm.max_children = 50/pm.max_children = 100/' /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html
COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
COPY . .
RUN chown -R apache:apache /var/www/html && chmod -R 755 /var/www/html
```

### docker-compose.yml Example

```yaml
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
    volumes:
      - ./:/var/www/html:delegated  # For development
    restart: unless-stopped
    networks:
      - backend-network
    depends_on:
      - db
    # Resource limits (recommended)
    mem_limit: 2g
    mem_reservation: 512m
    cpus: 2

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: "rootpassword"
      MYSQL_DATABASE: "your_database"
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - backend-network

volumes:
  mysql-data:

networks:
  backend-network:
    driver: bridge
```

## Performance Benchmarks

With the optimized base image, you can expect:

- **Simple API Endpoint** (no database): **~14ms**
- **CRUD Read Operation** (with database): **~31ms**
- **Framework Overhead**: **~14ms**
- **Database Query**: **~17ms** (for simple SELECT)

These are production-grade performance metrics.

## Using APCu for Caching

The base image includes APCu. Use it in your application:

```php
<?php
// Store data in cache
apc_store('user_' . $id, $userData, 3600);

// Retrieve from cache
$userData = apc_fetch('user_' . $id);

// Check if exists
if (apc_exists('user_' . $id)) {
    // Use cached data
}
```

## Using Redis Extension

The Redis extension is pre-installed. Connect to Redis:

```php
<?php
$redis = new Redis();
$redis->connect('redis', 6379); // 'redis' is your Redis container name

// Use Redis for caching
$redis->set('key', 'value', 3600);
$value = $redis->get('key');

// Use for sessions
ini_set('session.save_handler', 'redis');
ini_set('session.save_path', 'tcp://redis:6379');
```

## Monitoring Endpoints

### Health Check
```bash
curl http://localhost/fpm-ping
# Should return: pong
```

### PHP-FPM Status
```bash
curl http://localhost/fpm-status
# Returns detailed pool statistics
```

### Check OPcache Status
Create a simple PHP file:
```php
<?php
header('Content-Type: application/json');
echo json_encode(opcache_get_status(), JSON_PRETTY_PRINT);
```

## Customization

### Override PHP Settings

Add custom PHP configuration:

```dockerfile
RUN echo "custom.setting = value" >> /usr/local/etc/php/conf.d/custom.ini
```

### Override PHP-FPM Settings

Modify pool configuration:

```dockerfile
RUN sed -i 's/pm.max_children = 50/pm.max_children = 100/' /usr/local/etc/php-fpm.d/www.conf
```

### Override Apache Settings

Add custom Apache configuration:

```dockerfile
RUN echo "CustomSetting value" >> /etc/apache2/conf.d/custom.conf
```

### Add Additional PHP Extensions

```dockerfile
FROM gemvc/apache:latest

# Install additional extensions
RUN apk add --no-cache \
    some-dev-package \
    && docker-php-ext-install some-extension \
    && apk del some-dev-package

# ... rest of your Dockerfile
```

## Resource Requirements

### Minimum (Development)
- **RAM**: 512MB
- **CPU**: 1 core
- **Disk**: 500MB

### Recommended (Production)
- **RAM**: 2GB (supports 50 concurrent PHP workers)
- **CPU**: 2 cores
- **Disk**: 1GB+

### High Traffic (Production)
- **RAM**: 4GB+ (increase `pm.max_children` accordingly)
- **CPU**: 4+ cores
- **Disk**: 2GB+

## Troubleshooting

### Container Restarts Constantly

Check logs:
```bash
docker logs <container-name>
```

Common issues:
- Missing `.env` file
- Database connection issues
- Permission problems

### Slow Performance

1. Check OPcache is working:
```bash
curl http://localhost/check-opcache.php
```

2. Check PHP-FPM status:
```bash
curl http://localhost/fpm-status
```

3. Verify resource limits in docker-compose.yml

### Permission Errors

Ensure proper ownership:
```dockerfile
RUN chown -R apache:apache /var/www/html
```

### Redis Connection Failed

Ensure Redis service is running and accessible:
```yaml
# In docker-compose.yml
services:
  redis:
    image: redis:alpine
    networks:
      - backend-network
```

## Building the Base Image

If you want to build the base image yourself:

```bash
# Build the base image
docker build -f Dockerfile.base -t gemvc/apache:latest .

# Tag for registry (optional)
docker tag gemvc/apache:latest your-registry/gemvc/apache:latest

# Push to registry (optional)
docker push your-registry/gemvc/apache:latest
```

## Best Practices

1. **Layer Caching**: Copy `composer.json` before application code
2. **Production Builds**: Use `--no-dev` flag for Composer
3. **Optimize Autoloader**: Always use `--optimize-autoloader`
4. **Resource Limits**: Set appropriate limits in docker-compose.yml
5. **Health Checks**: Use built-in health check endpoints
6. **Logging**: All logs go to stdout/stderr (Docker best practice)
7. **Permissions**: Always set proper file permissions

## Security Considerations

- **Production Mode**: OPcache timestamp validation is disabled
- **Error Display**: Configure via `APP_ENV` in your `.env` file
- **File Permissions**: Base image sets secure defaults
- **User**: Runs as `apache` user (non-root)

## Support

For issues, questions, or contributions:
- Check GEMVC documentation
- Review Docker logs: `docker logs <container-name>`
- Check PHP-FPM status: `curl http://localhost/fpm-status`

## Version Information

- **Base Image**: `gemvc/apache:latest`
- **PHP Version**: 8.4
- **Apache Version**: 2.x (Alpine)
- **Alpine Version**: Latest

---

**Note**: This base image is optimized for production use. For development, you may want to enable OPcache timestamp validation or adjust other settings.

