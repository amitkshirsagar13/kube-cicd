#!/bin/sh
docker rm -f school-service student-service 
docker network disconnect --force bridge school-service student-service 

docker run -d --rm --name student-service -p 8999:8999 -e VPORT=8999 -e VHOST_CONSUL=$1 student-consul-service
docker run -d --rm --name school-service -p 8998:8998 -e VPORT=8998 -e VHOST_CONSUL=$1 school-consul-service