# GEMVC OpenSwoole Mac Base Image

This folder contains the Mac developer variant for GEMVC OpenSwoole.
Designed for Apple Silicon and Mac hosts running backend API workloads.

## Usage

```dockerfile
FROM gemvc/swoole-mac:latest

WORKDIR /var/www/html
COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
COPY . .
```

## Build

Build with multi-arch support:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t gemvc/swoole-mac:latest .
```

## Features

- OpenSwoole 25.2 + PHP 8.4
- APCu and OPcache enabled
- Redis and database-ready extensions
- Mac-friendly variant naming

## Notes

- This image is Linux-based and intended for Docker on Mac.
- Use it for backend or API development targeting iOS/macOS clients.
