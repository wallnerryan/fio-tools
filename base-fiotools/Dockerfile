# ---------- Stage 1: build a minimal gnuplot (no cairo/pango/harfbuzz) ----------
ARG ALPINE_VERSION=3.20
ARG GNUPLOT_VERSION=5.4.10
FROM alpine:${ALPINE_VERSION} AS gnuplot-build
ARG GNUPLOT_VERSION

RUN set -eux; \
    apk add --no-cache \
      build-base wget tar \
      gd-dev libpng-dev freetype-dev libjpeg-turbo-dev zlib-dev readline-dev; \
    mkdir -p /tmp/build && cd /tmp/build; \
    wget -O gnuplot.tar.gz \
      "https://downloads.sourceforge.net/project/gnuplot/gnuplot/${GNUPLOT_VERSION}/gnuplot-${GNUPLOT_VERSION}.tar.gz"; \
    tar -xzf gnuplot.tar.gz; \
    cd gnuplot-${GNUPLOT_VERSION}; \
    ./configure \
      --prefix=/usr \
      --without-x \
      --without-qt \
      --disable-wxwidgets \
      --without-aquaterm \
      --without-cairo \
      --without-lua \
      --with-gd; \
    make -j"$(nproc)"; \
    make install-strip

# ---------- Stage 2: build CPython WITHOUT sqlite ----------
ARG ALPINE_VERSION=3.20
ARG PY_VER=3.12.5
FROM alpine:${ALPINE_VERSION} AS python-build
ARG PY_VER

RUN set -eux; \
    apk add --no-cache \
      build-base wget tar xz \
      openssl-dev bzip2-dev zlib-dev libffi-dev \
      readline-dev ncurses-dev expat-dev; \
    mkdir -p /tmp/build && cd /tmp/build; \
    wget -O Python.tar.xz "https://www.python.org/ftp/python/${PY_VER}/Python-${PY_VER}.tar.xz"; \
    tar -xf Python.tar.xz; \
    cd Python-${PY_VER}; \
    ./configure \
      --prefix=/usr/local \
      --enable-optimizations \
      --with-lto \
      --with-ensurepip=install; \
    make -j"$(nproc)"; \
    make install; \
    /usr/local/bin/pip3 --no-cache-dir install --upgrade pip; \
    /usr/local/bin/pip3 --no-cache-dir install six

# ---------- Stage 3: runtime ----------
ARG ALPINE_VERSION=3.20
FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Ryan Wallner <ryan.wallner@portworx.com>"

# Minimal runtime: keep python3 (from our build), fio, tini, HTTPS tools,
# and libs needed by gnuplot (GD/png/jpeg/freetype/zlib/readline). No jq, no sqlite.
# Prefer 3.20 repos, but add a v3.21 alias for expat only
RUN set -eux; \
    printf '%s\n' \
      "https://dl-cdn.alpinelinux.org/alpine/v3.20/main" \
      "https://dl-cdn.alpinelinux.org/alpine/v3.20/community" \
      "@v321 https://dl-cdn.alpinelinux.org/alpine/v3.21/main" \
    > /etc/apk/repositories

# (optional) cache-buster so the layer re-runs when you change this arg
ARG APK_EXPAT_VERSION=2.7.2-r0

RUN set -eux; \
    apk add --no-cache \
      fio tini ca-certificates wget \
      libgd libpng freetype libjpeg-turbo zlib readline ttf-dejavu \
      "expat@v321>=${APK_EXPAT_VERSION}"

# sanity check (kept in layer logs)
RUN apk info -v expat && \
    ldd /usr/bin/gnuplot | grep -i expat || true

# Bring in our self-built gnuplot
COPY --from=gnuplot-build /usr/bin/gnuplot   /usr/bin/gnuplot
COPY --from=gnuplot-build /usr/share/gnuplot /usr/share/gnuplot

# Bring in our self-built Python (no sqlite-libs pulled in)
COPY --from=python-build /usr/local /usr/local

# Make fio’s gnuplot templates work headlessly / consistently
RUN set -eux; \
    sed -i 's/^set term .*/set term png size 1280,720/' /usr/share/fio/*.gpm; \
    sed -i 's|font "arial"|font "/usr/share/fonts/TTF/DejaVuSans.ttf"|' /usr/share/fio/*.gpm; \
    sed -i 's/^set pm3d at .*/set pm3d at s; set hidden3d; set pm3d scansbackward/' /usr/share/fio/graph3D.gpm

# OCP/K8s random-UID friendly perms
RUN set -eux; \
    mkdir -p /opt /tmp/fio-data; \
    chgrp -R 0 /opt /tmp/fio-data; \
    chmod -R g=u /opt /tmp/fio-data

VOLUME ["/tmp/fio-data"]
WORKDIR /tmp/fio-data

ENTRYPOINT ["/sbin/tini","--"]
CMD ["/bin/sh"]
