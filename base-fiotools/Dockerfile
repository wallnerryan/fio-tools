# ---------- Stage 1: build a minimal gnuplot (no cairo/pango/harfbuzz) ----------
ARG ALPINE_VERSION=3.20
ARG GNUPLOT_VERSION=5.4.10
FROM alpine:${ALPINE_VERSION} AS gnuplot-build
ARG GNUPLOT_VERSION

# Build gnuplot to avoid CVEs in upstreadm 3.20 alpine
# two criticals are in glib and harfbuzz pulled in by Alpine’s gnuplot stack (via cairo/pango).
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

# ---------- Stage 2: runtime ----------
ARG ALPINE_VERSION=3.20
FROM alpine:${ALPINE_VERSION}
LABEL maintainer="Ryan Wallner <ryan.wallner@portworx.com>"

# runtime deps (no cairo/pango/harfbuzz)
RUN set -eux; \
    apk add --no-cache \
      fio jq wget ca-certificates tini python3 py3-six \
      gd libpng freetype libjpeg-turbo zlib readline ncurses-libs ttf-dejavu

# bring in the self-built gnuplot + its shared data
COPY --from=gnuplot-build /usr/bin/gnuplot   /usr/bin/gnuplot
COPY --from=gnuplot-build /usr/share/gnuplot /usr/share/gnuplot

# Make fio’s gnuplot templates work headlessly:
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

