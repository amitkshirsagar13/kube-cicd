FROM alpine:3.3
LABEL maintainer="Amit Kshirsagar <amit.kshirsagar.13@gmail.com>"

ENV VERSION 2.2.1

RUN apk add --no-cache python
RUN apk add --no-cache py-pip
RUN apk add --no-cache curl
RUN pip install --upgrade pip
RUN pip install pbr
RUN pip install jenkins-job-builder