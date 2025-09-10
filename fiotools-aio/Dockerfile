# syntax=docker/dockerfile:1.6
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
LABEL maintainer="Ryan Wallner <ryan.wallner@portworx.com>"


# All-in-one: check -> run fio -> plot -> serve on 8000
# set owner and mode when copying
COPY run.sh   /opt/run.sh
COPY plot.sh  /opt/plot.sh
COPY check.sh /opt/check.sh
COPY runall.sh /opt/runall.sh

RUN chmod +x /opt/*.sh

# Fio2gnuplot helper (already in repo)
# If this file is located at the repo root as before, this copies it in.
COPY lib/fio2gnuplot /usr/local/bin/fio2gnuplot
RUN chmod +x /usr/local/bin/fio2gnuplot || true

EXPOSE 8000
WORKDIR /tmp/fio-data
CMD ["/opt/runall.sh"]
