# syntax=docker/dockerfile:1.6
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
LABEL maintainer="Ryan Wallner <ryan.wallner@portworx.com>"

# Uses fio2gnuplot to build graphs from *_bw* and *_iops* logs
# We reuse the project's plot.sh to keep behavior identical.
ADD plot.sh /opt/plot.sh
RUN chmod +x /opt/plot.sh

WORKDIR /tmp/fio-data
CMD ["/opt/plot.sh"]