#!/bin/bash

fio2gnuplot -t $PLOTNAME_bw -b -g -p *_bw*
fio2gnuplot -t $PLOTNAME_iops -b -g -p *_iops*
