# Docker Setup for STCMS

Minimal production-ready Docker image for STCMS.

## Features

- ✅ **Minimal image** - PHP 8.2 + Apache only
- ✅ **No Node.js** - Assets pre-built before pushing to image
- ✅ **Composer** - PHP dependencies installed during build
- ✅ **Production optimized** - OPcache, APCu enabled
- ✅ **Security hardened** - Apache security headers, non-root user

## Prerequisites

1. **Pre-build assets** before building Docker image:
   ```bash
   npm install
   npm run build
   ```
   This creates `public/assets/build/` with compiled React assets.

2. **No composer.json needed** - The Dockerfile installs `gemvc/stcms:1.6.2` directly, making the image independent and reproducible.

## Quick Start

### 1. Build assets (before Docker build)

```bash
npm install
npm run build
```

### 2. Build Docker image

```bash
docker-compose build
```

Or manually:
```bash
docker build -t stcms:latest .
```

### 3. Run container

```bash
docker-compose up -d
```

### 4. Check logs

```bash
docker-compose logs -f
```

## Build Process

The Dockerfile:
1. Installs PHP 8.2 with Apache
2. Installs required PHP extensions (zip, intl, mbstring, opcache, apcu)
3. Installs Composer
4. **Installs `gemvc/stcms:1.6.2` directly** - Fixed version for reproducibility
5. Copies application files (including pre-built assets and `.htaccess` files)
6. Verifies `.htaccess` files are present (root and `public/`)
7. Configures Apache and sets permissions

## Image Size

- **Base image**: ~150MB (php:8.2-apache)
- **Final image**: ~300-350MB (with dependencies)
- **No Node.js**: Saves ~200MB compared to including Node.js

## Apache Configuration

### .htaccess Files

The image includes both `.htaccess` files:
- **Root `.htaccess`** - Security rules and routing to `public/` folder
- **`public/.htaccess`** - Front controller routing and security headers

These are automatically included in the image and verified during build.

## Security

### Firewall Configuration

**Configure UFW on Docker HOST** (not in container):

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### Container Security

- Runs as `www-data` user (non-root)
- Apache security headers enabled
- PHP version hidden
- OPcache and APCu enabled for performance

## Environment Variables

Create `.env` file in project root:

```env
APP_ENV=production
CACHE_DRIVER=apcu
DEFAULT_LANGUAGE=en
API_BASE_URL=https://api.example.com
```

## Production Deployment

### Build and Push Workflow

```bash
# 1. Build assets locally
npm install
npm run build

# 2. Build Docker image
docker build -t your-registry/stcms:latest .

# 3. Push to registry
docker push your-registry/stcms:latest

# 4. Deploy on server
docker pull your-registry/stcms:latest
docker run -d -p 80:80 -p 443:443 your-registry/stcms:latest
```

## Troubleshooting

### Assets not found

Make sure you built assets before Docker build:
```bash
npm run build
```

### Composer install fails

The Dockerfile installs `gemvc/stcms:1.6.2` directly. If it fails:
- Check internet connection (needs to download from Packagist)
- Verify `gemvc/stcms:1.6.2` is available on Packagist

### Permission issues

```bash
docker exec -u root stcms-app chown -R www-data:www-data /var/www/html
```

## Why This Approach is Good

**Minimal image size** - No Node.js in production  
**Fast builds** - No npm install during Docker build  
**Security** - Smaller attack surface  
**Production ready** - Optimized for runtime performance  
**Clear separation** - Build assets separately, run in container  
**Independent image** - `gemvc/stcms:1.6.2` installed directly, no need for `composer.json`  
**Reproducible builds** - Fixed version ensures same image every time  
