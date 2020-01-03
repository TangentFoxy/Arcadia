#!/usr/bin/env bash

set -e # exit on any failure

moonc .
docker build -t guard13007/realms2:latest .
docer push guard13007/realms2:latest
