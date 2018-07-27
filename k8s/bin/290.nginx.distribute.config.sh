# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh
source k8s.conf
source cluster.conf

sudo rm -f nginx.conf

echo "[ ${GREEN}INFO${NC} ] Generating nginx config file"

cat > nginx.conf << EOF
user nginx;
worker_processes auto;

error_log   /var/log/nginx/error.log info;
pid         /var/run/nginx.pid;

load_module /usr/lib64/nginx/modules/ngx_stream_module.so;

events {
    worker_connections 1024;
}

stream {
    upstream apiserver {
        server ${MASTER_IP1}:6443 weight=5 max_fails=3 fail_timeout=30s;
        server ${MASTER_IP2}:6443 weight=5 max_fails=3 fail_timeout=30s;
        server ${MASTER_IP3}:6443 weight=5 max_fails=3 fail_timeout=30s;
    }

    server {
        listen ${LB_PORT};
        proxy_connect_timeout 1s;
        proxy_timeout 1s;
        proxy_pass apiserver;
    }
}

EOF

muser=$USER # cluster.conf USER, need to be OS user will work with only user/password login
for M in $M2 $M3; do
    host="${M}${SERVER_DOMAIN}"
    echo "[ ${GREEN}INFO${NC} ] Distributing nginx.conf to $muser@$host"
    # upload certs and distribution using scp
    sudo -S -u $USER scp nginx.conf $muser@$host:/tmp/
    # Execute distribution Script to move certs to right folders

    echo "[ ${BLUE}WARN${NC} ] Execute Below Set of commands :
    cd /tmp && ./101.setupNginx.sh && exit"
    sudo -S -u $USER ssh $muser@$host "sudo su - "
done

source 101.setupNginx.sh

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Nginx configuration distributed to Masters               ==="
echo "========================================================================="
