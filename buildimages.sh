#!/usr/bin/env bash
set -euo pipefail

NS="${FIOTOOLS_DOCKERHUB_USERNAME:-fiotools}"
TAG="${FIOTOOLS_DOCKERHUB_TAG:-tag}"
PUSH="${FIOTOOLS_DOCKERHUB_PUSH:-false}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
DOCKER_CONTEXT="${DOCKER_CONTEXT:-default}"

# NEW: knobs
NO_CACHE="${NO_CACHE:-false}"        # set to true/1/yes to force rebuilds
PULL_BASE="${PULL_BASE:-false}"      # set to true to always --pull parents
PROGRESS="${PROGRESS:-auto}"         # plain|tty|auto

echo "Using repo: $NS  tag: $TAG  platforms: $PLATFORMS  push: $PUSH  context: $DOCKER_CONTEXT  no_cache: $NO_CACHE  pull_base: $PULL_BASE"

tolower(){ printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]'; }
is_true(){ case "$(tolower "$1")" in 1|true|yes|y) return 0;; *) return 1;; esac; }

host_platform() {
  case "$(uname -m)" in
    x86_64|amd64)  echo "linux/amd64" ;;
    aarch64|arm64) echo "linux/arm64" ;;
    *)             echo "linux/amd64" ;;
  esac
}

dc(){ docker --context="$DOCKER_CONTEXT" "$@"; }

# ensure we’re on the intended context
docker context use "$DOCKER_CONTEXT" >/dev/null

# common flags applied to ALL builds
COMMON_FLAGS=(--progress "$PROGRESS")
if is_true "$NO_CACHE"; then
  COMMON_FLAGS+=(--no-cache)
fi
if is_true "$PULL_BASE"; then
  COMMON_FLAGS+=(--pull)
fi


BASE_REF="${NS}/base-fiotools:${TAG}"
GNUPLOT_VERSION="${GNUPLOT_VERSION:-5.4.10}"
PYVER="${PY_VER:-3.12.5}"

if is_true "$PUSH"; then
  # ---------- multi-arch build & push (buildx container driver) ----------
  # builder that can push multi-arch
  if ! dc buildx inspect fiotools >/dev/null 2>&1; then
    dc buildx create --name fiotools --driver docker-container --use >/dev/null
  else
    dc buildx use fiotools >/dev/null
  fi
  # qemu for cross-builds (idempotent)
  dc run --privileged --rm tonistiigi/binfmt --install all >/dev/null 2>&1 || true

  # Add attestations (required to satisfy Docker Scout / supply chain)
  ATTEST_FLAGS=(--provenance=mode=max --sbom=true)

  bx() {
    dc buildx build \
      "${ATTEST_FLAGS[@]}" \
      "${COMMON_FLAGS[@]}" \
      "$@" \
      --label org.opencontainers.image.source="https://github.com/wallnerryan/fio-tools" \
      --label org.opencontainers.image.revision="$(git rev-parse --short HEAD)" \
      --label org.opencontainers.image.created="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --label org.opencontainers.image.version="$TAG"
  }

  # 1) base -> push
  bx base-fiotools/ \
    -t "$BASE_REF" \
    --build-arg GNUPLOT_VERSION="$GNUPLOT_VERSION" \
    --build-arg PY_VER="$PYVER" \
    --platform "$PLATFORMS" --push

  # 2) dependents -> push (they’ll pull $BASE_REF from the registry)
  bx fio-genplots/   -t "${NS}/fio-genplots:${TAG}"   --build-arg BASE_IMAGE="$BASE_REF" --platform "$PLATFORMS" --push
  bx fio-tool/       -t "${NS}/fio-tool:${TAG}"       --build-arg BASE_IMAGE="$BASE_REF" --platform "$PLATFORMS" --push
  bx fio-plotserve/  -t "${NS}/fio-plotserve:${TAG}"  --build-arg BASE_IMAGE="$BASE_REF" --platform "$PLATFORMS" --push
  bx fiotools-aio/   -t "${NS}/fiotools-aio:${TAG}"   --build-arg BASE_IMAGE="$BASE_REF" --platform "$PLATFORMS" --push

else
  # ---------- local single-arch builds (classic docker build) ----------
  REQ_PLAT="$(echo "$PLATFORMS" | tr -d ' ')"
  HOST_PLAT="$(host_platform)"
  if [[ "$REQ_PLAT" != "$HOST_PLAT" ]]; then
    echo "ERROR: Local load must match host platform. Set PLATFORMS=$HOST_PLAT or set FIOTOOLS_DOCKERHUB_PUSH=true." >&2
    exit 3
  fi

  # 1) base -> local daemon
  dc build base-fiotools/ \
    -t "$BASE_REF" \
    --build-arg GNUPLOT_VERSION="$GNUPLOT_VERSION" \
    --build-arg PY_VER="$PYVER" \
    "${COMMON_FLAGS[@]}"

  # 2) dependents -> use local base tag; no registry pull needed
  dc build fio-genplots/   -t "${NS}/fio-genplots:${TAG}"   --build-arg BASE_IMAGE="$BASE_REF"
  dc build fio-tool/       -t "${NS}/fio-tool:${TAG}"       --build-arg BASE_IMAGE="$BASE_REF"
  dc build fio-plotserve/  -t "${NS}/fio-plotserve:${TAG}"  --build-arg BASE_IMAGE="$BASE_REF"
  dc build fiotools-aio/   -t "${NS}/fiotools-aio:${TAG}"   --build-arg BASE_IMAGE="$BASE_REF"
fi

echo "Done."
