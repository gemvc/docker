# GEMVC Nginx Runtime (Production Ready)

![Docker Image Size](https://img.shields.io/docker/image-size/gemvc/nginx/latest)
![PHP Version](https://img.shields.io/badge/php-8.4-777BB4.svg)
![OS](https://img.shields.io/badge/os-alpine-blue.svg)
![Nginx](https://img.shields.io/badge/server-nginx-green.svg)

[cite_start]This is the official **production-ready** runtime environment for the **GEMVC Framework**[cite: 1]. [cite_start]It features a highly optimized **Nginx** web server coupled with **PHP 8.4 FPM** [cite: 1] [cite_start]built on a lightweight **Alpine Linux** base[cite: 1].

While optimized for GEMVC, this image is **framework-agnostic** and can run any modern PHP application requiring high performance and strict security.

---

## 🚀 Technical Stack & Features

### Core Components
- [cite_start]**OS:** Alpine Linux (Lightweight & Secure) [cite: 1]
- [cite_start]**PHP:** 8.4 (FPM) [cite: 1]
- [cite_start]**Web Server:** Nginx (Pre-configured for high traffic) [cite: 2]
- **Package Manager:** Composer (Latest binary pre-installed)

### [cite_start]Included Extensions [cite: 3]
The image comes with essential extensions enabled by default:
- **Database:** `pdo`, `pdo_mysql`
- **Caching/Session:** `redis`
- **Optimization:** `opcache`
- **Utilities:** `intl`, `zip`, `icu-libs`

### [cite_start]Performance Tuning [cite: 4]
`php.ini` is pre-configured for maximum speed:
- **JIT Compiler:** Enabled in Tracing mode (`opcache.jit=tracing`)
- **Opcache:** Fully enabled with optimized buffer sizes
- **Memory Limit:** Set to `256M`
- **Upload Limit:** Increased to `64M`

---

## 🛡️ Security Measures

This image implements a "Secure by Default" philosophy using a hardened Nginx configuration (`security.conf`):

### 1. Server Hardening
- [cite_start]**Non-Root User:** Application runs as `www-data` (UID 82)[cite: 5].
- [cite_start]**Strict Permissions:** Files are set to `640` and directories to `750`[cite: 5].
- [cite_start]**Information Hiding:** Nginx version and PHP headers are hidden (`server_tokens off`, `expose_php=Off`)[cite: 4].

### 2. Nginx Security Config (`security.conf`)
- **Security Headers:** Includes `X-Frame-Options`, `X-XSS-Protection`, `Content-Security-Policy`, and `Referrer-Policy`.
- **Protected Directories:** Access to sensitive folders like `/app`, `/vendor`, `/bin`, `/config`, and `/templates` is blocked.
- **Upload Protection:** Execution of `.php` scripts inside the `/uploads` directory is denied.
- **Hidden Files:** Access to dotfiles (e.g., `.env`, `.git`) is strictly forbidden.
- **Basic WAF:** Blocks common SQL Injection and XSS patterns in query strings.

---

## 📦 How to Use

This is a **Base Image**. You should use it in your project's `Dockerfile` to load your application code.

### 1. Create a `Dockerfile`

```dockerfile
# Use the GEMVC Runtime as base
FROM gemvc/nginx:latest

# Set working directory
WORKDIR /var/www/html

# Copy dependency definitions first (to leverage Docker cache)
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of your application code
COPY . .

# IMPORTANT: Fix permissions for the runtime user
RUN chown -R www-data:www-data /var/www/html

###GEMVC Routing Logic
´´´
location / {
    try_files $uri $uri/ @gemvc_routing;
}

location @gemvc_routing {
    # Rewrites URLs to GEMVC format: /path -> index.php?_gemvc_url_path=path
    rewrite ^/(.*)$ /index.php?_gemvc_url_path=$1 last;
}
´´´

###Ignored Files
To keep the image small and secure, the following are excluded from the build context:

    .git, .idea, .vscode

    .env (Use Docker environment variables instead)

    vendor (Dependencies are installed during build)

    tests, docs, README.md

    docker-compose.yml, Dockerfile