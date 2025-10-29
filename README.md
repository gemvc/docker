# GEMVC Docker Images

[![Docker Pulls](https://img.shields.io/docker/pulls/gemvc/docker)](https://hub.docker.com/r/gemvc/docker)
[![Docker Stars](https://img.shields.io/docker/stars/gemvc/docker)](https://hub.docker.com/r/gemvc/docker)
[![GitHub License](https://img.shields.io/github/license/gemvc/docker)](https://github.com/gemvc/docker/blob/main/LICENSE)

Official Docker images for GEMVC Framework providing optimized, ready-to-use environments for development and production.

## 🚀 Quick Start

Choose your preferred server configuration:

### Nginx + PHP-FPM
```dockerfile
FROM gemvc/docker:nginx-latest

# Copy your application
COPY . /var/www/html
```

### Apache + mod_php
```dockerfile
FROM gemvc/docker:apache-latest

# Copy your application
COPY . /var/www/html
```

### OpenSwoole
```dockerfile
FROM gemvc/docker:swoole-latest

# Copy your application
COPY . /var/www/html
```

### Alpine (Lightweight)
```dockerfile
FROM gemvc/docker:alpine-latest

# Copy your application
COPY . /var/www/html
```

## 🏷️ Supported Tags

| Tag | Description | Size |
|-----|-------------|------|
| `nginx-latest`, `nginx-php8.2` | Nginx + PHP-FPM configuration | ~400MB |
| `apache-latest`, `apache-php8.2` | Apache + mod_php configuration | ~450MB |
| `swoole-latest`, `swoole-php8.2` | OpenSwoole configuration | ~300MB |
| `alpine-latest`, `alpine-php8.2` | Lightweight Alpine-based | ~200MB |

## ✨ Features

### Pre-installed Extensions
- ✅ PDO (MySQL, PostgreSQL)
- ✅ Redis
- ✅ OpCache
- ✅ Composer

### Performance Optimizations
- ✅ OpCache configured for production
- ✅ PHP-FPM tuned for high performance
- ✅ Nginx/Apache optimized configurations
- ✅ Memory limits adjusted for modern applications

### Security
- ✅ Production-hardened configurations
- ✅ Regular security updates
- ✅ Minimal attack surface
- ✅ Built-in health checks

### Development Experience
- ✅ Ready-to-use environments
- ✅ Consistent across team
- ✅ Standard port mappings
- ✅ Clear documentation

## 📦 What's Included

### All Images Include
- PHP 8.2
- Composer
- PDO Extensions (MySQL, PostgreSQL)
- Redis Extension
- OpCache
- Essential PHP Extensions
- Health Check Support
- Production Configurations

### Variant-Specific Features

#### Nginx Variant
- Nginx latest stable
- PHP-FPM optimized
- Upload limit: 64MB
- Max execution time: 30s
- Memory limit: 256MB

#### Apache Variant
- Apache 2.4
- mod_php configured
- .htaccess support
- URL rewriting enabled
- Security rules included

#### OpenSwoole Variant
- OpenSwoole latest
- Event-driven architecture
- High-performance server
- WebSocket support
- Coroutine support

#### Alpine Variant
- Alpine Linux base
- Minimal image size
- Same features as Nginx
- Optimized for CI/CD

## 🛠️ Usage Examples

### Basic Usage
```bash
# Pull the image
docker pull gemvc/docker:nginx-latest

# Run a container
docker run -d -p 80:80 --name my-gemvc-app gemvc/docker:nginx-latest
```

### With Docker Compose
```yaml
version: '3.8'

services:
  app:
    image: gemvc/docker:nginx-latest
    ports:
      - "80:80"
    volumes:
      - ./:/var/www/html
    environment:
      - PHP_MEMORY_LIMIT=256M
      - UPLOAD_MAX_FILESIZE=64M
```

### Custom Configuration
```dockerfile
FROM gemvc/docker:nginx-latest

# Custom PHP configuration
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

# Custom Nginx configuration
COPY nginx.conf /etc/nginx/sites-available/default

# Your application
COPY . /var/www/html
```

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_MEMORY_LIMIT` | 256M | PHP memory limit |
| `UPLOAD_MAX_FILESIZE` | 64M | Maximum upload size |
| `POST_MAX_SIZE` | 64M | Maximum POST size |
| `MAX_EXECUTION_TIME` | 30 | Script timeout |

### Volumes

| Path | Purpose |
|------|---------|
| `/var/www/html` | Application files |
| `/etc/nginx/sites-available` | Nginx configuration |
| `/usr/local/etc/php/conf.d` | PHP configuration |

## 🚨 Health Checks

All images include automatic health checks:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1
```

## 📈 Performance Tuning

### OpCache Settings
```ini
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
```

## 🔒 Security

- Regular security updates
- Minimal base images
- No development tools in production
- Proper file permissions
- Security-focused configurations

## 📦 Building from Source

```bash
# Clone the repository
git clone https://github.com/gemvc/docker.git
cd docker

# Build specific variant
cd nginx
docker build -t gemvc/docker:nginx-latest .
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋 Support

- 📫 Issues: [GitHub Issues](https://github.com/gemvc/docker/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/gemvc/docker/discussions)
- 📖 Documentation: [GEMVC Docs](https://gemvc.de/docs)

## ✨ Acknowledgements

- GEMVC Framework Team
- Docker Community
- OpenSwoole Team
- PHP Community

---

Built with ❤️ by the GEMVC Team
