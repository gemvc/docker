# STCMS Base Docker Image

Production-ready base Docker image for STCMS applications. This is a **base image** that you extend in your own projects.

## Features

- ✅ **Base image architecture** - Reusable foundation for all STCMS applications
- ✅ **Minimal image** - PHP 8.2 + Apache only
- ✅ **No Node.js** - Assets should be pre-built in your application
- ✅ **Composer** - PHP dependencies installed during build
- ✅ **Production optimized** - OPcache, APCu enabled
- ✅ **Security hardened** - Apache security headers, non-root user
- ✅ **Both .htaccess files included** - Root and `public/.htaccess` embedded in base image

## What is This?

This is a **base image repository** for STCMS. It provides a ready-to-use foundation that includes:
- PHP 8.2 + Apache
- All required PHP extensions
- `gemvc/stcms:x.x.x` package pre-installed (version specified in Dockerfile)
- Both `.htaccess` files (root and `public/`)
- Production-optimized configuration

**You extend this base image in your own project** with your application code.

## Building the Base Image

### Build the base image:

```bash
# Replace x.x.x with the STCMS version (e.g., 1.6.2)
docker build -f Dockerfile.x.x.x -t stcms-base:x.x.x .
```

### Push to registry (optional, for team use):

```bash
# Replace x.x.x with the STCMS version
docker tag stcms-base:x.x.x your-registry/stcms-base:x.x.x
docker push your-registry/stcms-base:x.x.x
```

## Using the Base Image in Your Project

### 1. Create a Dockerfile in your project:

```dockerfile
# Use the STCMS base image
# Replace x.x.x with the STCMS version (e.g., 1.6.2)
FROM stcms-base:x.x.x
# Or from registry:
# FROM your-registry/stcms-base:x.x.x

WORKDIR /var/www/html

# Copy your application files
COPY --chown=www-data:www-data . .

# Verify .htaccess files (base has them, but verify)
RUN test -f .htaccess && test -f public/.htaccess || exit 1

# Set permissions
RUN chown -R www-data:www-data /var/www/html
```

See `Dockerfile.example` for a complete example.

### 2. Build your application image:

```bash
# Make sure base image exists first (replace x.x.x with version, e.g., 1.6.2)
docker build -f Dockerfile.x.x.x -t stcms-base:x.x.x .

# Then build your application
docker build -t my-stcms-app:latest .
```

### 3. Customize as needed:

- Override `.htaccess` files if needed
- Add additional Composer dependencies
- Add custom setup scripts
- Configure environment variables
- Add volumes, etc.

## Base Image Contents

The `Dockerfile.x.x.x` (where `x.x.x` is the STCMS version, e.g., `1.6.2`) includes:
1. PHP 8.2 with Apache
2. Required PHP extensions (zip, intl, mbstring, opcache, apcu)
3. Composer
4. **`gemvc/stcms:x.x.x` pre-installed** - Fixed version for reproducibility (version specified in Dockerfile)
5. **Root `.htaccess`** - Security rules and routing to `public/` folder
6. **`public/.htaccess`** - Front controller routing and security headers
7. Apache and PHP production configuration
8. Proper permissions and document root setup

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

### Base Image Workflow

```bash
# 1. Build base image (replace x.x.x with version, e.g., 1.6.2)
docker build -f Dockerfile.x.x.x -t your-registry/stcms-base:x.x.x .

# 2. Push base image to registry
docker push your-registry/stcms-base:x.x.x
```

### Application Workflow (in your project)

```bash
# 1. Build assets locally (in your project)
npm install
npm run build

# 2. Build application image (extends base)
docker build -t your-registry/my-stcms-app:latest .

# 3. Push application image
docker push your-registry/my-stcms-app:latest

# 4. Deploy on server
docker pull your-registry/my-stcms-app:latest
docker run -d -p 80:80 -p 443:443 your-registry/my-stcms-app:latest
```

## Troubleshooting

### Assets not found

Make sure you built assets before Docker build:
```bash
npm run build
```

### Composer install fails

The Dockerfile installs `gemvc/stcms:x.x.x` directly (version specified in Dockerfile). If it fails:
- Check internet connection (needs to download from Packagist)
- Verify the specified `gemvc/stcms` version is available on Packagist

### Permission issues

```bash
docker exec -u root stcms-app chown -R www-data:www-data /var/www/html
```

## Why This Base Image Approach is Good

**Easy maintenance** - Update STCMS version in one place, all apps benefit  
**Faster builds** - Base layers cached, only application code rebuilt  
**Consistent environment** - All apps use same base configuration  
**Minimal image size** - No Node.js in production  
**Security** - Smaller attack surface, security headers included  
**Production ready** - Optimized for runtime performance  
**Both .htaccess files included** - No need to copy them in every project  
**Reproducible builds** - Fixed version ensures same base image every time  
**Team collaboration** - Share base image via registry, consistent environment  
