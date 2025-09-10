# syntax=docker/dockerfile:1.6
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
LABEL maintainer="Ryan Wallner <ryan.wallner@portworx.com>"

# Runs the user-provided job(s)
# (Existing entry script expects JOBFILES, and writes fio.output)
# See run.sh in repo: runs "fio --output=fio.output $JOBFILES"
ADD run.sh /opt/run.sh
RUN chmod +x /opt/run.sh

WORKDIR /tmp/fio-data
CMD ["/opt/run.sh"]
