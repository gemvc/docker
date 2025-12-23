# GEMVC Apache Base Docker Image

Production-ready base Docker image for GEMVC applications with Apache, PHP 8.4, and optimized performance configurations.

## Features

- ✅ **Alpine-based** - Minimal image size (~380MB)
- ✅ **PHP 8.4** - Latest PHP version with all required extensions
- ✅ **Apache** - High-performance web server
- ✅ **Composer** - PHP dependency manager pre-installed
- ✅ **Performance optimized** - OPcache with JIT, Gzip compression, browser caching
- ✅ **Security hardened** - Security headers, sensitive files/directories blocked
- ✅ **GEMVC routing** - `.htaccess` with GEMVC routing (`_gemvc_url_path`) included
- ✅ **TraceKit ready** - Error logging disabled (handled by TraceKit integration)

## What is This?

This is a **base image repository** for GEMVC applications. It provides a ready-to-use foundation that includes:
- Alpine Linux
- Apache web server
- PHP 8.4 with all required extensions (pdo, pdo_mysql, zip, gd, intl, mbstring, xml, curl, bcmath, opcache)
- Composer
- GEMVC `.htaccess` routing configuration
- Production-optimized Apache and PHP settings
- Security configurations

**You extend this base image in your own project** with your application code.

## Building the Base Image

### Build the base image:

```bash
# Replace x.x.x with the version (e.g., 1.0.0)
docker build -t gemvc-apache:x.x.x .
```

### Push to registry (optional, for team use):

```bash
# Replace x.x.x with the version
docker tag gemvc-apache:x.x.x your-registry/gemvc-apache:x.x.x
docker push your-registry/gemvc-apache:x.x.x
```

## Using the Base Image in Your Project

### 1. Create a Dockerfile in your project:

```dockerfile
# Use the GEMVC Apache base image
# Replace x.x.x with the version (e.g., 1.0.0)
FROM gemvc-apache:x.x.x
# Or from registry:
# FROM your-registry/gemvc-apache:x.x.x

WORKDIR /var/www/html

# Copy your application files
COPY --chown=www-data:www-data . .

# If you need to install additional Composer dependencies
# COPY composer.json composer.lock ./
# RUN composer install --no-dev --optimize-autoloader

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;
```

### 2. Build your application image:

```bash
# Make sure base image exists first (replace x.x.x with version, e.g., 1.0.0)
docker build -t gemvc-apache:x.x.x .

# Then build your application
docker build -t my-gemvc-app:latest .
```

### 3. Customize as needed:

- Override `.htaccess` if needed (base has GEMVC routing)
- Add additional Composer dependencies
- Add custom setup scripts
- Configure environment variables
- Add volumes, etc.

## Base Image Contents

The base image includes:

1. **Alpine Linux** - Minimal base OS
2. **Apache 2** - Web server with modules: rewrite, headers, deflate, expires
3. **PHP 8.4** - With extensions: pdo, pdo_mysql, zip, gd, intl, mbstring, xml, curl, bcmath, opcache, phar
4. **Composer** - PHP dependency manager
5. **GEMVC `.htaccess`** - Routing configuration with `_gemvc_url_path` parameter
6. **Security configuration** - Blocks sensitive files and directories
7. **Performance configuration** - OPcache, Gzip, browser caching
8. **MPM Event configuration** - High-performance Apache worker model (if available)

## Configuration Files

The base image includes these configuration files:

- **`php.ini`** - PHP production settings (TraceKit-integrated error handling)
- **`opcache.ini`** - OPcache with JIT (256MB buffer, tracing mode)
- **`security.conf`** - Security headers and file/directory blocking
- **`performance.conf`** - Apache performance optimizations
- **`php.conf`** - PHP handler configuration
- **`mpm_event.conf`** - MPM Event worker configuration
- **`.htaccess`** - GEMVC routing and performance settings

## Security Features

### Blocked File Types
- `.json`, `.env`, `.htaccess`, `.ini`, `.log`, `.sh`, `.bak`, `.lock`

### Blocked Directories
- `vendor/`, `app/`, `bin/`, `templates/`

### Security Headers
- X-Frame-Options: SAMEORIGIN
- X-XSS-Protection: 1; mode=block
- X-Content-Type-Options: nosniff
- Referrer-Policy: strict-origin-when-cross-origin

## Performance Features

- **OPcache** - 256MB memory, JIT enabled (tracing mode)
- **Gzip Compression** - Level 6 for optimal compression
- **Browser Caching** - Optimized cache headers for static assets
- **MPM Event** - Non-blocking, high-performance worker model
- **KeepAlive** - Optimized connection reuse

## GEMVC Routing

The base image includes `.htaccess` with GEMVC routing:

```apache
RewriteRule ^(.*)$ index.php?_gemvc_url_path=$1 [QSA,L]
```

This routes all requests to `index.php` with the `_gemvc_url_path` parameter, which GEMVC uses for routing.

## Error Handling

The base image is configured for **TraceKit integration**:
- `display_errors = Off` - Errors not shown to users
- `log_errors = Off` - No file logging (TraceKit handles tracking)
- `error_reporting` - Enabled for TraceKit to catch errors

GEMVC framework handles error display in development environment.

## Image Size

- **Base image**: ~380MB (Alpine + Apache + PHP 8.4 + extensions)
- **Minimal footprint** - Alpine-based for smallest possible size

## Production Deployment

### Base Image Workflow

```bash
# 1. Build base image (replace x.x.x with version, e.g., 1.0.0)
docker build -t your-registry/gemvc-apache:x.x.x .

# 2. Push base image to registry
docker push your-registry/gemvc-apache:x.x.x
```

### Application Workflow (in your project)

```bash
# 1. Build application image (extends base)
docker build -t your-registry/my-gemvc-app:latest .

# 2. Push application image
docker push your-registry/my-gemvc-app:latest

# 3. Deploy on server
docker pull your-registry/my-gemvc-app:latest
docker run -d -p 80:80 your-registry/my-gemvc-app:latest
```

## Environment Variables

You can set environment variables when running the container:

```bash
docker run -d -p 80:80 \
  -e APP_ENV=production \
  -e DB_HOST=mysql \
  -e DB_NAME=gemvc \
  your-registry/my-gemvc-app:latest
```

## Volumes

Mount your application code or configuration:

```bash
docker run -d -p 80:80 \
  -v /path/to/your/app:/var/www/html \
  your-registry/my-gemvc-app:latest
```

## Troubleshooting

### Apache won't start

Check Apache configuration:
```bash
docker run --rm your-image httpd -t
```

### PHP extensions missing

All required extensions are pre-installed. If you need additional ones, install via PECL in your application Dockerfile.

### Permission issues

```bash
docker exec -u root your-container chown -R www-data:www-data /var/www/html
```

### Check which MPM is active

```bash
docker run --rm your-image httpd -M | grep mpm
```

## Why This Base Image Approach is Good

**Easy maintenance** - Update Apache/PHP version in one place, all apps benefit  
**Faster builds** - Base layers cached, only application code rebuilt  
**Consistent environment** - All apps use same base configuration  
**Minimal image size** - Alpine-based for smallest footprint  
**Security** - Smaller attack surface, security headers included  
**Production ready** - Optimized for runtime performance  
**GEMVC routing included** - No need to copy `.htaccess` in every project  
**TraceKit integrated** - Error handling configured for TraceKit  
**Team collaboration** - Share base image via registry, consistent environment

## Example Dockerfile

See `Dockerfile.example` (if available) for a complete example of extending this base image.

## License

[Add your license information here]

