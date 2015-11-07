FROM ubuntu:14.10
MAINTAINER <Ryan Wallner ryan.wallner@clusterhq.com>

RUN sed -i -e 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get -y update && apt-get -y install fio gnuplot

WORKDIR /tmp/fio-data
ENTRYPOINT ["/usr/bin/fio2gnuplot"]
