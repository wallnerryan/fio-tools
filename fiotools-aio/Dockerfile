FROM ubuntu:14.10
MAINTAINER <Ryan Wallner ryan.wallner@clusterhq.com>

RUN sed -i -e 's/archive.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get -y update && apt-get -y install fio wget python2.7 gnuplot

# Check ENV vars
ADD check.sh /opt/check.sh
RUN chmod +x /opt/check.sh

# Run the FIO Job
VOLUME /tmp/fio-data
ADD run.sh /opt/run.sh
RUN chmod +x /opt/run.sh
WORKDIR /tmp/fio-data

# Generate plots
ADD plot.sh /opt/plot.sh
RUN chmod +x /opt/plot.sh

# Add all-in-one script
ADD runall.sh /opt/runall.sh
RUN chmod +x /opt/runall.sh

# Add modified script to y axis is set accurately
ADD fio2gnuplot /usr/bin/fio2gnuplot
RUN chmod +x /usr/bin/fio2gnuplot

EXPOSE 8000
CMD ["/opt/runall.sh"] 
