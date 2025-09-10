#!/usr/bin/env bash
set -euo pipefail

NS="${FIOTOOLS_DOCKERHUB_USERNAME:-fiotools}"
TAG="${FIOTOOLS_DOCKERHUB_TAG:-tag}"
PUSH="${FIOTOOLS_DOCKERHUB_PUSH:-false}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"

echo "Using repo: $NS  tag: $TAG  platforms: $PLATFORMS  push: $PUSH"

# ---- helpers ---------------------------------------------------------------

is_true() {
  case "${1,,}" in
    1|true|yes|y) return 0 ;;
    *)            return 1 ;;
  esac
}

host_load_platform() {
  # choose the platform we can --load into the host daemon
  case "$(uname -m)" in
    x86_64) echo "linux/amd64" ;;
    aarch64|arm64) echo "linux/arm64" ;;
    *) echo "linux/amd64" ;;
  esac
}

ensure_builder() {
  local name="$1" driver="$2"
  if ! docker buildx inspect "$name" >/dev/null 2>&1; then
    docker buildx create --name "$name" --driver "$driver" --use >/dev/null
  else
    docker buildx use "$name" >/dev/null
  fi
}

# ---- builder selection -----------------------------------------------------

if is_true "$PUSH"; then
  # multi-arch + push -> container driver
  ensure_builder fiotools docker-container
  # enable qemu emulation for cross-builds (idempotent)
  docker run --privileged --rm tonistiigi/binfmt --install all >/dev/null
  BUILD_EXTRA=(--push --platform "$PLATFORMS")
else
  # local single-arch build that can see host images -> docker driver
  ensure_builder fiotools-local docker
  LOAD_PLAT="$(host_load_platform)"
  BUILD_EXTRA=(--load --platform "$LOAD_PLAT")
  echo "Local load platform: $LOAD_PLAT"
fi

build() {
  local img="$1" dir="$2"
  shift 2 || true
  echo "==> Building $img from $dir"
  docker buildx build "$dir" -t "$img" "${BUILD_EXTRA[@]}" "$@"
}

# ---- build order -----------------------------------------------------------

# 1) base (must be first)
BASE_REF="${NS}/base-fiotools:${TAG}"
GNUPLOT_VERSION=5.4.10
build "$BASE_REF" base-fiotools/ --build-arg GNUPLOT_VERSION=$GNUPLOT_VERSION 

# 2) dependents (pass the base via ARG)
build "${NS}/fio-genplots:${TAG}"  fio-genplots/   --build-arg BASE_IMAGE="$BASE_REF"
build "${NS}/fio-tool:${TAG}"      fio-tool/       --build-arg BASE_IMAGE="$BASE_REF"
build "${NS}/fio-plotserve:${TAG}" fio-plotserve/  --build-arg BASE_IMAGE="$BASE_REF"
build "${NS}/fiotools-aio:${TAG}"  fiotools-aio/   --build-arg BASE_IMAGE="$BASE_REF"

echo "Done."

