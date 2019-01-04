FROM base-fiotools
MAINTAINER <Ryan Wallner ryan.wallner@portworx.com>

# Add modified script to y axis is set accurately
ADD lib/fio2gnuplot /usr/bin/fio2gnuplot
RUN chmod +x /usr/bin/fio2gnuplot

WORKDIR /tmp/fio-data
ENTRYPOINT ["/usr/bin/fio2gnuplot"]
