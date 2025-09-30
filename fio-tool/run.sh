#!/bin/sh

[ -z "$JOBFILES" ] && echo "Need to set JOBFILES" && exit 1;
echo "Found jobs: $JOBFILES"

# We really want no old data in here except the fio script
mv /tmp/fio-data/*.fio /tmp/
rm -rf /tmp/fio-data/*
mv /tmp/*fio /tmp/fio-data/

if [ ! -z "$REMOTEFILES" ]; then
    IFS=' '
    echo "Gathering remote files..."
    for file in $REMOTEFILES; do
  	wget --directory-prefix=/tmp/fio-data/ "$file"
    done 
fi

#!/bin/sh

echo "Running FIO job $JOBFILES"
fio $JOBFILES 2>&1 | tee fio.output

