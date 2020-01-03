#!/usr/bin/env bash

set -e # exit on any failure

moonc .
sudo docker build -t guard13007/realms2:latest .
#docker push guard13007/realms2:latest
