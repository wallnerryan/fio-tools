#!/bin/bash
docker build -t fiotools/fio-genplots fio-genplots/
docker build -t fiotools/fio-tool fio-tool/
docker build -t fiotools/fio-plotserve fio-plotserve/
