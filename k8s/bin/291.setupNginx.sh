# Copyright (C) Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh
source k8s.conf
source cluster.conf

echo ""
# Install Nginx
if [ -x "$(command -v nginx)" ]; then
    echo "[ ${GREEN}INFO${NC} ] nginx already installed"
    echo "[ ${GREEN}INFO${NC} ] ${BLUE}`nginx --version`${NC}"
else
    echo "[ ${BLUE}WARN${NC} ] Installing nginx"
    yum install -y epel-release
    yum install -y nginx
    echo "[ ${GREEN}INFO${NC} ] ${BLUE}`nginx --version`${NC}"
fi


sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
sudo mv nginx.conf /etc/nginx/nginx.conf

sudo systemctl enable nginx && sudo systemctl start nginx
#sudo systemctl status nginx

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Nginx LoadBalancer setup completed                       ==="
echo "========================================================================="