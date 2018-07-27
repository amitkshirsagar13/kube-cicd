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
access_log  /var/log/nginx/access.log;
error_log   /var/log/nginx/error.log info;
pid         /var/run/nginx.pid;

load_module /usr/lib64/nginx/modules/ngx_stream_module.so;

events {
    worker_connections 1024;
    multi_accept on;
}
http {
	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	# server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	##
	# SSL Settings
	##
	ssl on;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;
	ssl_certificate /etc/pki/nginx/nginx.crt;
    ssl_certificate_key /etc/pki/nginx/private/nginx.key;

	##
	# Gzip Settings
	##

	gzip on;

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;


	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	#include /etc/nginx/sites-enabled/*;
	include /etc/nginx/k8m/k8m.conf;
}

EOF

cat > k8m.conf << EOF

map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
}

server {
   listen         80;
   return 301 https://$host$request_uri;
}

upstream websocket {
        server localhost:9090;
}

server {
   listen       80 http2;
   server_name  api.k8m.k8cluster.io;
   location / {
     proxy_pass http://localhost:8443/;
     proxy_set_header Host $host;
     proxy_set_header X-Real-IP $remote_addr;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_set_header X-Forwarded-Proto $scheme;
   }
}

server {
   listen       443 ssl http2;
   server_name  api.k8m.k8cluster.io;
   location / {
     proxy_pass https://localhost:6443/;
     proxy_set_header Host $host;
     proxy_set_header X-Real-IP $remote_addr;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_set_header X-Forwarded-Proto $scheme;
   }
}

server {
   listen       443 ssl http2;
   server_name  cockpit.k8m.k8cluster.io;
   location / {
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header X-Real-IP  $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;

        # needed for websocket
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        # change scheme of "Origin" to http
        proxy_set_header Origin http://$host;

        gzip off;
        add_header X-Frame-Options "SAMEORIGIN";
        proxy_pass http://websocket;
   }
}

server {
   listen       443 ssl http2 default_server;
   server_name  *.k8m.k8cluster.io;
   root         /usr/share/nginx/html;
   index index.html index.htm;
   ssl_certificate "/etc/pki/nginx/server.crt";
   ssl_certificate_key "/etc/pki/nginx/private/server.key";
   location / {
     proxy_pass https://localhost:30443/;
     proxy_set_header Host $host;
     proxy_set_header X-Real-IP $remote_addr;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_set_header X-Forwarded-Proto $scheme;
   }
}

EOF

muser=$USER # cluster.conf USER, need to be OS user will work with only user/password login
for M in $M2 $M3; do
    host="${M}${SERVER_DOMAIN}"
    echo "[ ${GREEN}INFO${NC} ] Distributing nginx.conf to $muser@$host"
    # upload certs and distribution using scp
    sudo -S -u $USER scp nginx.conf k8m.conf $muser@$host:/tmp/
    # Execute distribution Script to move certs to right folders

    echo "[ ${BLUE}WARN${NC} ] Execute Below Set of commands :
    cd /tmp && ./291.setupNginx.sh && exit"
    sudo -S -u $USER ssh $muser@$host "sudo su - "
done

source 101.setupNginx.sh

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Nginx configuration distributed to Masters               ==="
echo "========================================================================="
