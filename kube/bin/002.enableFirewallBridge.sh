# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash

firewall-cmd --add-port=6443/tcp --permanent ; firewall-cmd --relaod

modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables