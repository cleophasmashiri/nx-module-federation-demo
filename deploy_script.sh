#!/bin/bash

docker run -d -p 4200:4200 --name shell cleophasmashiri/shell
docker run -d -p 4201:4201 --name mfe1 cleophasmashiri/mfe1