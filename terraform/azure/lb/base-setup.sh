#!/bin/sh
echo "`date` : Started Setup.... " > /tmp/log.script.log
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
echo "`date` : Configure docker-ce" >> /tmp/log.script.log
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
echo "`date` : Installing Docker docker-ce" >> /tmp/log.script.log
yum install -y docker-ce
echo "`date` : Enable and start docker-ce" >> /tmp/log.script.log
systemctl enable docker
systemctl start docker

echo "`date` : Finished installing Docker docker-ce" >> /tmp/log.script.log
exit
