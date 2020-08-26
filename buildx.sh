#!/usr/bin/env sh

REPO=mikenye
IMAGE=modesmixer2
LINUX_PLATFORMS=('386' 'amd64' 'arm/v7' 'arm64')

TMPPLATFORMS=""
for p in "${LINUX_PLATFORMS[@]}"; do
  TMPPLATFORMS+="linux/$p,"
done
PLATFORMS=${TMPPLATFORMS::-1}

docker context use x86_64
export DOCKER_CLI_EXPERIMENTAL="enabled"
docker buildx use homecluster

# Build & push latest platform specific
for p in "${LINUX_PLATFORMS[@]}"; do
  sanitised_p="$(echo $p | tr -d "/")"
  docker buildx build -t ${REPO}/${IMAGE}:latest_${sanitised_p} --compress --push --platform "linux/$p" .
done

# Build & push version specific platform specific
PLATFORM_VERSIONS=()
for p in "${LINUX_PLATFORMS[@]}"; do
  sanitised_p="$(echo $p | tr -d "/")"
  case "$p" in
  386 | amd64)
    CONTEXT="x86_64"
    ;;
  arm/v7)
    CONTEXT="arm32v7"
    ;;
  arm64)
    CONTEXT="arm64"
    ;;
  *)
    echo "ERROR: unknown context"
    exit 1
    ;;
  esac
  docker --context="$CONTEXT" pull ${REPO}/${IMAGE}:latest_${sanitised_p}
  VERSION=$(docker --context="$CONTEXT" run --rm --entrypoint cat ${REPO}/${IMAGE}:latest_${sanitised_p} /VERSIONS | grep -i modesmixer2 | cut -d ' ' -f 2 | tr -d ' ')
  PLATFORM_VERSIONS+=("$VERSION")
  docker buildx build -t ${REPO}/${IMAGE}:${VERSION}_${sanitised_p} --compress --push --platform "linux/$p" .
done

# Check to see that we have a common version between all platforms
for v in "${PLATFORM_VERSIONS[@]}"; do
  if [[ "$v" != "${PLATFORM_VERSIONS[0]}" ]]; do
    echo "WARNING: Cannot create multi-arch image, as versions are different between architectures."
    echo "${PLATFORM_VERSIONS[@]}"
    exit 0
  fi
done

# Build & push latest
docker buildx build -t ${REPO}/${IMAGE}:latest --compress --push --platform "${PLATFORMS}" .

# Get piaware version from latest
docker pull ${REPO}/${IMAGE}:latest
VERSION=$(docker run --rm --entrypoint cat ${REPO}/${IMAGE}:latest /VERSIONS | grep -i modesmixer2 | cut -d ' ' -f 2 | tr -d ' ')

# Build & push version-specific
docker buildx build -t "${REPO}/${IMAGE}:${VERSION}" --compress --push --platform "${PLATFORMS}" .
