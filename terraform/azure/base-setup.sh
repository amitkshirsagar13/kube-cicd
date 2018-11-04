#!/usr/bin/env bash

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce

sudo yum install epel-release
sudo yum install -y python-pip
sudo pip install docker-compose
sudo yum upgrade python*

# Install Luarocks and dependencies with it.


mkdir /var/docker
# Get your oauth-validator code cloned from git repository here and run luarock commands here.
#git clone https://github.com/roura356a/metar.git /var/docker/metar



exit