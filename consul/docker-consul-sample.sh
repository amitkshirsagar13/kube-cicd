#!/bin/sh
docker run -d --rm --name student-service -p 8899:8899 tudent-consul-service
docker run -d --rm --name school-service -p 8898:8898 school-consul-service