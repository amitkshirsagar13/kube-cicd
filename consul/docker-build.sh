#!/bin/sh
docker build -t student-consul-service . student.Dockerfile
docker build -t school-consul-service . school.Dockerfile

