# GEMVC Apache Mac Base Image

Mac-friendly base image for GEMVC PHP apps (Apple Silicon and Intel).

## App Dockerfile (developers)

```dockerfile
FROM gemvc/apache-mac:latest

WORKDIR /var/www/html
COPY composer.json composer.lock* ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
COPY . .
RUN chown -R apache:apache /var/www/html
```

No Apache vhost or extra HTTP config in the application repo.

## Files in this repo

| File                | Role             |
|---------------------|------------------|
| `Dockerfile`        | Base image build |
| `apache-vhost.conf` | Apache virtual host (fixes missing `</FilesMatch>` bug) |
| `Dockerfile.user`   | Example app layer|

## Test base image locally

```bash
docker build -t gemvc/apache-mac:latest .
docker run --rm -p 8080:80 gemvc/apache-mac:latest
```

Check logs: no `httpd: Syntax error` on `vhost.conf`. Full stack testing uses each app’s own `docker-compose.yml` (e.g. BackendBetAutomation).

## Publish new version

```bash
docker build -t gemvc/apache-mac:latest .
docker buildx build --platform linux/amd64,linux/arm64 -t gemvc/apache-mac:latest --push .
```

Developers then:

```bash
docker pull gemvc/apache-mac:latest
docker compose build --no-cache web && docker compose up -d
```

## If web container keeps restarting

Old images had a broken vhost built with `echo` (missing `</FilesMatch>`). Rebuild and push this repo, then pull the new tag.
