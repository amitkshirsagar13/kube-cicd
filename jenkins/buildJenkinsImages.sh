#!/bin/bash
docker build -t amitkshirsagar13/k8s-jenkins-plugin . -f k8s-plugins.Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-master . -f k8s-jenkins.Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-slave . -f k8s-jenkins-slave/Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-dotnet . -f k8s-jenkins-dotnet/Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-alpine . -f k8s-jenkins-alpine/Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-job-builder . -f k8s-jenkins-job-builder/Dockerfile
