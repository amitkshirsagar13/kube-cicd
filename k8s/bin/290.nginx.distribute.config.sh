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
	ssl_certificate /etc/pki/nginx/nginx.pem;
  ssl_certificate_key /etc/pki/nginx/private/nginx-key.pem;

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
   location / {
     proxy_pass https://localhost:30443/;
     proxy_set_header Host $host;
     proxy_set_header X-Real-IP $remote_addr;
     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
     proxy_set_header X-Forwarded-Proto $scheme;
   }
}

EOF

sudo /usr/local/bin/cfssl print-defaults csr |sudo tee nginx.json
sudo sed -i '0,/CN/{s/example\.net/'"$PEERNAME${SERVER_DOMAIN}"'/}' nginx.json
sudo sed -i 's/www\.example\.net/'"$PRIVATEIP"'/' nginx.json
sudo sed -i 's/example\.net/'$PEERNAME'/' nginx.json
sudo sed -i 's/ecdsa/rsa/' nginx.json
sudo sed -i 's/256/2048/' nginx.json
sudo /usr/local/bin/cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server nginx.json |sudo /usr/local/bin/cfssljson -bare nginx

muser=$USER # cluster.conf USER, need to be OS user will work with only user/password login
for M in $M2 $M3; do
    host="${M}${SERVER_DOMAIN}"
    echo "[ ${GREEN}INFO${NC} ] Distributing nginx.conf to $muser@$host"
    # upload certs and distribution using scp
    sudo -S -u $USER scp nginx.conf k8m.conf nginx.pem nginx-key.pem nginx.csr $muser@$host:/tmp/
    # Execute distribution Script to move certs to right folders

    echo "[ ${BLUE}WARN${NC} ] Execute Below Set of commands :
    cd /tmp && ./291.setupNginx.sh && exit"
    sudo -S -u $USER ssh $muser@$host "sudo su - "
done

source 101.setupNginx.sh

helminit

kubectl create clusterrolebinding nginx --clusterrole cluster-admin --serviceaccount=nginx:default
helm install --name nginx  --namespace nginx stable/nginx-ingress --set controller.service.type=NodePort --set controller.service.nodePorts.https=30443 --set controller.service.nodePorts.http=30080
kubectl create namespace dev
kubectl create secret tls dev-cert --namespace dev --key /tmp/tls.key --cert /tmp/tls.crt

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Nginx configuration distributed to Masters               ==="
echo "========================================================================="
