#!/usr/bin/env bash

apt-get update && apt-get install -y apt-transport-https ca-certificates curl git-core software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update && apt-get install -y docker-ce docker-compose
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose

# Install Luarocks and dependencies with it.

mkdir /var/docker
# Get your oauth-validator code cloned from git repository here and run luarock commands here.
git clone https://github.com/roura356a/metar.git /var/docker/metar
