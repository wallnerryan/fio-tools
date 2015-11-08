#!/bin/bash
docker build -t fiotools/fio-genplots fio-genplots/
docker build -t fiotools/fio-tool fio-tool/
docker build -t fiotools/fio-plotserve fio-plotserve/
docker build -t fiotools/fiotools-aio fiotools-aio/
