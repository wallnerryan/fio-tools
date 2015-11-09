#!/bin/bash

[ -z "$JOBFILES" ] && echo "Need to set JOBFILES" && exit 1;
echo "Found jobs: $JOBFILES"

[ -z "$PLOTNAME" ] && echo "Need to set PLOTOPTS" && exit 1;
echo "Received $PLOTNAME"

# We really want no old data in here
rm -rf /tmp/fio-data/*

if [ ! -z "$REMOTEFILES" ]; then
    IFS=' '
    echo "Gathering remote files..."
    for file in $REMOTEFILES; do
  	wget --directory-prefix=/tmp/fio-data/ "$file"
    done 
fi
