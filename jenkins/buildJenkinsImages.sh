#!/bin/bash
docker build -t amitkshirsagar13/k8s-jenkins-plugin . -f k8s-plugins.Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-master . -f k8s-jenkins.Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-slave . -f k8s-jenkins-slave/Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-dotnet . -f k8s-jenkins-dotnet/Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-alpine . -f k8s-jenkins-alpine/Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-job-builder . -f k8s-jenkins-job-builder/Dockerfile
docker build -t amitkshirsagar13/k8s-jenkins-kubernetes . -f k8s-jenkins-kubernetes/Dockerfile

docker build -t amitkshirsagar13/k8s-jenkins-master-init . -f k8s-jenkins-master-init/Dockerfile

docker push amitkshirsagar13/k8s-jenkins-plugin
docker push amitkshirsagar13/k8s-jenkins-master
docker push amitkshirsagar13/k8s-jenkins-slave
docker push amitkshirsagar13/k8s-jenkins-dotnet
docker push amitkshirsagar13/k8s-jenkins-alpine
docker push amitkshirsagar13/k8s-jenkins-job-builder
docker push amitkshirsagar13/k8s-jenkins-kubernetes