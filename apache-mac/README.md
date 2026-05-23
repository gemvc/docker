# GEMVC Apache Mac Base Image

This folder contains the Mac developer variant for GEMVC Apache.
It is designed to be used by Mac developers and Apple Silicon hosts as a dedicated backend base image.

## Usage

```dockerfile
FROM gemvc/apache-mac:latest

WORKDIR /var/www/html
COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
COPY . .
```

## Build

Build this image with Apple Silicon / Intel Mac support:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t gemvc/apache-mac:latest .
```

## Features

- Apache 2 + PHP 8.4 FPM
- Composer pre-installed
- Redis and APCu extensions
- OPcache enabled and tuned
- Mac-friendly variant naming for development workflows

## Notes

- This is still a Linux-based Docker image.
- It is intended for backend API and PHP development on Mac hosts.
- For iOS or macOS native app builds you still need Apple toolchains outside this container.
