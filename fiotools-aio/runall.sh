#!/bin/sh

OUTDIR="${OUTDIR:-plots}"

echo "Running all-in-one..."
sh /opt/check.sh
sh /opt/run.sh
sh /opt/plot.sh

echo "Starting server..."
python3 -m http.server 8000 
