#!/bin/sh
docker kill `docker ps|grep jenkins-master|tr -s " " "|"|cut -d "|" -f1` && \
    docker rm `docker ps --no-trunc -aq` && \
    docker image rm `docker images|grep jenkins-master|tr -s " " "|"|cut -d "|" -f3`