# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh
source k8s.conf
source cluster.conf

echo "[ ${GREEN}INFO${NC} ] Generating nginx ingress daemonset on all nodes"

kubectl apply -f common/ns-and-sa.yaml
kubectl create secret tls nginx-tls-secret --namespace nginx-ingress --key /etc/pki/nginx/private/nginx-key.pem --cert /etc/pki/nginx/nginx.pem

kubectl apply -f common/nginx-config.yaml
kubectl apply -f rbac/rbac.yaml
kubectl apply -f daemon-set/nginx-ingress.yaml

sleep 5
pods nginx-ingress

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Nginx Ingress configuration deployed all nodes           ==="
echo "========================================================================="
