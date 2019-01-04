FROM ubuntu:18.10
MAINTAINER <Ryan Wallner ryan.wallner@portworx.com>

RUN apt-get -y update
RUN apt-get -y install fio \
   wget \
   libqt5gui5 \
   gnuplot \
   python2.7 

# Bug "gnuplot: error while loading shared libraries: libQt5Core.so.5: cannot open shared object file: No such file or directory"
# https://askubuntu.com/questions/1041588/virtualbox-not-launching-on-ubuntu-18-04-qt-lib-problem
RUN apt-get remove -y libqt5core5a && apt-get install -y libqt5core5a