#!/bin/sh
docker build -t student-consul-service . -f student.Dockerfile
docker build -t school-consul-service . -f school.Dockerfile

