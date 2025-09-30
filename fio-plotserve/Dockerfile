# syntax=docker/dockerfile:1.6
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
LABEL maintainer="Ryan Wallner <ryan.wallner@portworx.com>"

# Static file server for /tmp/fio-data on port 8000
EXPOSE 8000
WORKDIR /tmp/fio-data
CMD ["python3","-m","http.server","8000"]

