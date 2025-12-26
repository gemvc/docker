# GEMVC OpenSwoole Docker Image

Official Docker base image for GEMVC Framework OpenSwoole applications.

## 📋 Overview

This directory contains the base Docker image (`Dockerfile`) that provides a production-ready OpenSwoole environment for all GEMVC users. The image includes OpenSwoole 25.2 with PHP 8.4 on Alpine Linux, pre-configured with essential PHP extensions and performance optimizations.

## 🏗️ Structure

- **`Dockerfile`** - Base image for all GEMVC OpenSwoole applications
  - Published to: `gemvc/swoole:latest`
  - Includes: OpenSwoole 25.2, PHP 8.4, extensions, OPcache, APCu
  
- **`Dockerfile.user`** - Example showing how users can use the base image
  - Demonstrates multi-stage build pattern
  - Shows dependency installation and optimization

- **`docker-compose.yml`** - Development environment setup
  - Includes OpenSwoole service and MySQL database
  - Configured for local development

## ✨ What's Included

### Base Image Features

- **OpenSwoole 25.2** with PHP 8.4 on Alpine Linux
- **PHP Extensions:**
  - `pdo_mysql` - MySQL database support
  - `pdo_pgsql` - PostgreSQL database support
  - `opcache` - OPcache for performance
  - `apcu` - APCu for user data caching
- **Performance Optimizations:**
  - OPcache JIT enabled with tracing mode
  - OPcache buffer size: 128M
  - APCu shared memory: 128M
  - Optimized OPcache settings for production
- **Tools:**
  - Composer pre-installed
  - curl for health checks
- **Security:**
  - Runs as `www-data` user (non-root)
  - Minimal attack surface (Alpine-based)

## 🚀 Quick Start

### Using the Base Image

Create a `Dockerfile` in your project:

```dockerfile
FROM gemvc/swoole:latest

WORKDIR /var/www/html

# Copy composer files
COPY composer.json composer.lock ./

# Install dependencies
RUN composer install --no-dev \
    --optimize-autoloader \
    --classmap-authoritative \
    --no-interaction

# Copy application files
COPY . .

# Optimize autoloader
RUN composer dump-autoload --optimize --classmap-authoritative

EXPOSE 9501

CMD ["php", "index.php"]
```

### Multi-Stage Build (Recommended)

For production, use a multi-stage build to reduce image size:

```dockerfile
# Build stage
FROM gemvc/swoole:latest AS builder

WORKDIR /var/www/html

COPY composer.json composer.lock ./

# Install dependencies with optimizations
RUN composer install --no-dev \
    --ignore-platform-reqs \
    --optimize-autoloader \
    --classmap-authoritative \
    --no-scripts \
    --no-interaction

# Runtime stage
FROM gemvc/swoole:latest

WORKDIR /var/www/html

# Copy vendor from builder
COPY --from=builder /var/www/html/vendor ./vendor

# Copy application files
COPY . .

# Optimize autoloader
RUN composer dump-autoload --optimize --classmap-authoritative

EXPOSE 9501

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9501/ || exit 1

CMD ["php", "index.php"]
```

See `Dockerfile.user` for a complete example.

## 🔧 Configuration

### OPcache Settings

The base image includes optimized OPcache configuration:

```ini
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=20000
opcache.validate_timestamps=0
opcache.jit=tracing
opcache.jit_buffer_size=128M
```

### APCu Settings

APCu is configured for user data caching:

```ini
apc.enable_cli=1
apc.shm_size=128M
```

### Custom Configuration

You can override or extend these settings by adding your own PHP configuration files:

```dockerfile
FROM gemvc/swoole:latest

# Add custom PHP configuration
COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

# Your application files
COPY . /var/www/html
```

## 🏥 Health Check

The base image includes a health check that verifies the OpenSwoole server is responding:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9501/ || exit 1
```

You can override this in your application's Dockerfile if needed.

## 🛠️ Development

### Using Docker Compose

For local development, use the provided `docker-compose.yml`:

```bash
# Build and start services
docker-compose up -d

# View logs
docker-compose logs -f openswoole

# Stop services
docker-compose down
```

The compose file includes:
- OpenSwoole service (port 9501)
- MySQL 8.0 database (port 3306)
- Volume mounts for live code reloading
- Network configuration

### Building the Base Image

To build the base image locally:

```bash
cd swoole
docker build -t gemvc/swoole:latest -f Dockerfile .
```

### Testing Your Application

```bash
# Build your application image
docker build -t my-gemvc-app -f Dockerfile.user .

# Run the container
docker run -d -p 9501:9501 --name my-app my-gemvc-app

# Check health
docker ps
docker inspect --format='{{.State.Health.Status}}' my-app
```

## 📦 Ports

- **9501** - Default OpenSwoole HTTP server port

You can change this in your application configuration if needed.

## 🔒 Security

- Runs as non-root user (`www-data`)
- Minimal base image (Alpine Linux)
- No unnecessary packages or services
- Production-hardened PHP and OpenSwoole configurations

## 📝 Version Information

- **Base Image:** `openswoole/openswoole:25.2-php8.4-alpine`
- **PHP Version:** 8.4
- **OpenSwoole Version:** 25.2
- **OS:** Alpine Linux
- **Image Version:** 5.2

## 🤝 Contributing

When contributing to the base image:

1. Test changes locally before submitting
2. Ensure backward compatibility
3. Update version numbers appropriately
4. Document any new features or breaking changes

## 📚 Additional Resources

- [GEMVC Framework Documentation](https://gemvc.de/docs)
- [OpenSwoole Documentation](https://openswoole.com/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

---

Built with ❤️ by the GEMVC Team

