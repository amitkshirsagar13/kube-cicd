#!/bin/sh
docker rm -f school-service student-service 
docker run -d --rm --name student-service -p 8999:8999 -e VPORT=8999 student-consul-service
docker run -d --rm --name school-service -p 8998:8998 -e VPORT=8998 school-consul-service