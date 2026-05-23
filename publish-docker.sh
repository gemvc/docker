#!/usr/bin/env bash
set -euo pipefail

# Build and push GEMVC Mac developer Docker images.
# Mac variants are published as 1.0.0 and latest.

NAMESPACE="${NAMESPACE:-gemvc}"
VERSION="${VERSION:-1.0.0}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"

echo "Publishing Docker images to Docker Hub namespace: ${NAMESPACE}"
echo "Version tag: ${VERSION}"
echo "Platforms: ${PLATFORMS}"

# NOTE:
# 1) Run `docker login` first.
# 2) Create these repositories on Docker Hub (recommended):
#    - ${NAMESPACE}/apache-mac
#    - ${NAMESPACE}/nginx-mac
#    - ${NAMESPACE}/swoole-mac
#    - ${NAMESPACE}/stcms-mac

build_and_push() {
  local image_name="$1"
  local context_dir="$2"

  echo "Building and pushing ${NAMESPACE}/${image_name}:${VERSION} and :latest"
  docker buildx build \
    --platform "${PLATFORMS}" \
    --push \
    -t "${NAMESPACE}/${image_name}:${VERSION}" \
    -t "${NAMESPACE}/${image_name}:latest" \
    "./${context_dir}"
}

build_and_push "apache-mac" "apache-mac"
build_and_push "nginx-mac" "nginx-mac"
build_and_push "swoole-mac" "swoole-mac"
build_and_push "stcms-mac" "stcms-mac"

echo "Publish completed successfully."
