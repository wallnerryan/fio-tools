FROM base-fiotools
MAINTAINER <Ryan Wallner ryan.wallner@portworx.com>

VOLUME /tmp/fio-data
ADD run.sh /opt/run.sh
RUN chmod +x /opt/run.sh
WORKDIR /tmp/fio-data
CMD ["/opt/run.sh"] 
