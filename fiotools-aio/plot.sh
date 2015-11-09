#!/bin/bash

fio2gnuplot -t $PLOTNAME-bw -b -g -p '*_bw*'
fio2gnuplot -t $PLOTNAME-iops -i -g -p '*_iops*'
