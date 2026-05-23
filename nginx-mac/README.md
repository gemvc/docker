# GEMVC Nginx Mac Base Image

This folder contains the Mac developer variant for GEMVC Nginx.
It is designed for Mac hosts and Apple Silicon-friendly backend development.

## Usage

```dockerfile
FROM gemvc/nginx-mac:latest

WORKDIR /var/www/html
COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
COPY . .
```

## Build

Build with multi-architecture support:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t gemvc/nginx-mac:latest .
```

## Features

- Nginx + PHP-FPM with optimized PHP settings
- Composer pre-installed
- Redis extension enabled
- OPcache tuned for performance
- Mac-friendly variant naming for developers

## Notes

- This image remains Linux-based for Docker compatibility.
- It is intended for gemvc backend/API development on Mac hosts.
