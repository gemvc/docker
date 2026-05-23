#!/usr/bin/env bash
set -euo pipefail

# Build and push GEMVC Mac developer Docker images.
# Mac variants are published as 1.0.0 and latest.

# NOTE: Make sure you are logged in to Docker Hub.
# docker login

# Mac developer variants
docker buildx build --platform linux/amd64,linux/arm64 -t gemvc/apache-mac:1.0.0 -t gemvc/apache-mac:latest ./apache-mac
# docker push gemvc/apache-mac:1.0.0
# docker push gemvc/apache-mac:latest

docker buildx build --platform linux/amd64,linux/arm64 -t gemvc/nginx-mac:1.0.0 -t gemvc/nginx-mac:latest ./nginx-mac
# docker push gemvc/nginx-mac:1.0.0
# docker push gemvc/nginx-mac:latest

docker buildx build --platform linux/amd64,linux/arm64 -t gemvc/swoole-mac:1.0.0 -t gemvc/swoole-mac:latest ./swoole-mac
# docker push gemvc/swoole-mac:1.0.0
# docker push gemvc/swoole-mac:latest

docker buildx build --platform linux/amd64,linux/arm64 -t gemvc/stcms-mac:1.0.0 -t gemvc/stcms-mac:latest ./stcms-mac
# docker push gemvc/stcms-mac:1.0.0
# docker push gemvc/stcms-mac:latest

echo "Build completed. Uncomment push commands once you are ready to publish."
