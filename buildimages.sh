#!/bin/bash

echo "Enter your Dockerhub Username or a prefix for the images..."
DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME:-myfiotools}

docker build -t base-fiotools base-fiotools/
docker build -t fiotools/fio-genplots fio-genplots/
docker build -t fiotools/fio-tool fio-tool/
docker build -t fiotools/fio-plotserve fio-plotserve/
docker build -t fiotools/fiotools-aio fiotools-aio
docker tag base-fiotools $DOCKERHUB_USERNAME/base-fiotools
docker tag fiotools/fio-genplots $DOCKERHUB_USERNAME/fio-genplots
docker tag fiotools/fio-tool $DOCKERHUB_USERNAME/fio-tool
docker tag fiotools/fio-plotserve $DOCKERHUB_USERNAME/fio-plotserve
docker tag fiotools/fiotools-aio $DOCKERHUB_USERNAME/fiotools-aio
