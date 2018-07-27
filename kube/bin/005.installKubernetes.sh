# Copyright (C) Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet kubeadm kubectl

systemctl start kubelet && systemctl enable kubelet

echo ' Change kuberetes cgroup-driver to "cgroupfs"'
docker info | grep -i cgroup
sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
systemctl restart kubelet

kubeadm init --config /home/amit_kshirsagar_13/kube-cicd/kube/config/kubeadm.yaml

mkdir -p $HOME/.kube
$HOME/.kube/config
cp /etc/kubernetes/admin.conf $HOME/.kube/config
cp /etc/kubernetes/admin.conf /home/amit_kshirsagar_13/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
chown $(id -u):$(id -g) /home/amit_kshirsagar_13/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
