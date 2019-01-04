#!/bin/bash

[ -z "$JOBFILES" ] && echo "Need to set JOBFILES" && exit 1;
echo "Running $JOBFILES"

# We really want no old data in here except the fio script
mv /tmp/fio-data/*.fio /tmp/
rm -rf /tmp/fio-data/*
mv /tmp/*fio /tmp/fio-data/

if [ ! -z "$REMOTEFILES" ]; then
    # We really want no old data in here
    rm -rf /tmp/fio-data/*
    IFS=' '
    echo "Gathering remote files..."
    for file in $REMOTEFILES; do
  	wget --directory-prefix=/tmp/fio-data/ "$file"
    done 
fi

fio --output=fio.output $JOBFILES 
