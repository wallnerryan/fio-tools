#!/bin/bash

sh /opt/check.sh
sh /opt/run.sh
sh /opt/plot.sh

python -m SimpleHTTPServer 8000
