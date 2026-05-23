# GEMVC STCMS Mac Base Image

This folder contains the Mac developer variant for GEMVC STCMS.
It is designed for Mac hosts and Apple Silicon-friendly Docker development.

## Usage

```dockerfile
FROM gemvc/stcms-mac:latest

WORKDIR /var/www/html
COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
COPY . .
```

## Build

Build with multi-architecture support:

```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  --build-arg STCMS_VERSION=">=1.6.2" \
  -t gemvc/stcms-mac:latest .
```

`stcms-mac` image tags are platform/runtime tags and can be independent
from the bundled `gemvc/stcms` package version selected by `STCMS_VERSION`.

## Features

- Apache + PHP 8.2 for STCMS
- APCu caching enabled
- Production-ready Apache settings
- Mac-friendly variant naming for developers

## Notes

- This image is Linux-based and intended for Docker on Mac.
- It is optimized for backend/API development workflows.
