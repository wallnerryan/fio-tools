# FIO-Tools

![Alt text](http://i.imgur.com/3oFD3XP.png "Plot Example")
![Alt text](http://i.imgur.com/5vUItaO.png "Plot Example")

#### *Important*
- *Your FIO `JOBFILES` should reference a `directory=/my/mounted/volume" to test against docker volumes

### To use with docker and docker volumes 
```
docker run -e REMOTEFILES="https://gist.githubusercontent.com/wallnerryan/fd0146ee3122278d7b5f/raw/cdd8de476abbecb5fb5c56239ab9b6eb3cec3ed5/job.fio" -v /tmp/fio-data:/tmp/fio-data --volume-driver flocker -v myvol1:/myvol -e JOBFILES=job.fio wallnerryan/fio-tool
```

To produce graphs, run the genplots container, `-p <pattern of your log files>`
```
docker run -v /tmp/fio-data:/tmp/fio-data wallnerryan/fio-genplots -t MySimple4kReadTest -b -g -p *_bw*
```

Simply serve them on port 8000
```
docker run -p 8000:8000 -d -v /tmp/fio-data:/tmp/fio-data wallnerryan/fio-plotserve
```

### To use with docker-machine/boot2docker

You can use a remote fit configuration file using the REMOTEFILES env variable.
```
docker run -e REMOTEFILES="https://gist.githubusercontent.com/wallnerryan/fd0146ee3122278d7b5f/raw/d089b6321746fe2928ce3f89fe64b437d1f669df/job.fio" -e JOBFILES=job.fio -v /Users/wallnerryan/Desktop/fio:/tmp/fio-data wallnerryan/fio-tool
```

(or)

If you have a directory that already has them in it
```
docker run -v /Users/wallnerryan/Desktop/fio:/tmp/fio-data -e JOBFILES=job.fio wallnerryan/fio-tool
```

To produce graphs, run the genplots container, `-p <pattern of your log files>`
```
docker run -v /Users/wallnerryan/Desktop/fio:/tmp/fio-data wallnerryan/fio-genplots -t MySimple4kReadTest -b -g -p *_bw*
```

Simply serve them on port 8000
```
docker run -v /Users/wallnerryan/Desktop/fio:/tmp/fio-data -d -p 8000:8000 wallnerryan/fio-plotserve
```

###  To use with docker that is *not* boot2docker or docker-machine , /tmp/fio-data is a still a VOLUME

You can use a remote configuration script
```
docker run -e REMOTEFILES="https://gist.githubusercontent.com/wallnerryan/fd0146ee3122278d7b5f/raw/2eb7d0ae9b77fa5a93662fe8088df2d83fff9ab2/job.fio" -v /tmp/fio-data:/tmp/fio-data -e JOBFILES=job.fio wallnerryan/fio-tool
```
(or)

You can create a directory and put it locally on the server where the container will run
```
mkdir /tmp/fio-data
cp <your FIO job file> /tmp/fio-data/
docker run -v /tmp/fio-data:/tmp/fio-data -e JOBFILES=<your FIO job> wallnerryan/fio-tool
```

To produce graphs, run the genplots container, `-p <pattern of your log files>`
```
docker run -v /tmp/fio-data:/tmp/fio-data wallnerryan/fio-genplots -t MySimple4kReadTest -b -g -p *_bw*
```

Simply serve them on port 8000
```
docker run -p 8000:8000 -d -v /tmp/fio-data:/tmp/fio-data wallnerryan/fio-plotserve
```

#### Notes

- The fio-tools container will clean up the /tmp/fio-data volume by default when you re-run it. If you want to save any data, copy this data out or save the files locally.
- When you serve on port 8000, you will have a list of all logs created and plots created, click on the `.png` files to see graph (see below for example screen)


![Alt text](http://i.imgur.com/nksQkZi.png "Served Files")
