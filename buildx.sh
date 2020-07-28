#!/usr/bin/env sh

REPO=mikenye
IMAGE=modesmixer2
PLATFORMS="linux/amd64,linux/arm/v7"

docker context use x86_64
export DOCKER_CLI_EXPERIMENTAL="enabled"
docker buildx use homecluster

# Build & push latest
docker buildx build -t ${REPO}/${IMAGE}:latest --compress --push --platform "${PLATFORMS}" .

# Get piaware version from latest
docker pull ${REPO}/${IMAGE}:latest
VERSION=$(docker run --rm --entrypoint cat ${REPO}/${IMAGE}:latest /VERSIONS | grep -i modesmixer2 | cut -d ' ' -f 2 | tr -d ' ')

# Build & push version-specific
docker buildx build -t "${REPO}/${IMAGE}:${VERSION}" --compress --push --platform "${PLATFORMS}" .
