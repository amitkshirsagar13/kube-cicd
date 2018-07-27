# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source isRoot.sh
source colorCode.sh
source k8s.conf

echo ""
# Install Docker
if [ -x "$(command -v docker)" ]; then
    echo "[ ${GREEN}INFO${NC} ] docker already installed"
    echo "[ ${GREEN}INFO${NC} ] ${BLUE}`docker --version`${NC}"
else
    echo "[ ${BLUE}WARN${NC} ] Installing docker"
    wget -c -O /tmp/docker-ce-selinux-${DOCKERVERSION}.${HOSTOS}.noarch.rpm https://download.docker.com/linux/${HOSTOS}/7/x86_64/stable/Packages/docker-ce-selinux-${DOCKERVERSION}.${HOSTOS}.noarch.rpm
    wget -c -O /tmp/docker-ce-${DOCKERVERSION}.${HOSTOS}.x86_64.rpm https://download.docker.com/linux/${HOSTOS}/7/x86_64/stable/Packages/docker-ce-${DOCKERVERSION}.${HOSTOS}.x86_64.rpm

    chmod +x /tmp/docker-ce-selinux-${DOCKERVERSION}.${HOSTOS}.noarch.rpm
    chmod +x /tmp/docker-ce-${DOCKERVERSION}.${HOSTOS}.x86_64.rpm

    yum -y install /tmp/docker-ce-selinux-${DOCKERVERSION}.${HOSTOS}.noarch.rpm
    yum -y install /tmp/docker-ce-${DOCKERVERSION}.${HOSTOS}.x86_64.rpm

    systemctl enable docker && systemctl daemon-reload
    systemctl restart docker && systemctl status docker

    rm -f /tmp/docker-ce-selinux-${DOCKERVERSION}.${HOSTOS}.noarch.rpm
    rm -f /tmp/docker-ce-${DOCKERVERSION}.${HOSTOS}.x86_64.rpm
fi

if [ ! -f /usr/lib/systemd/system/docker.service ]; then
    echo "[ ${RED}ERROR${NC} ] Docker installation failed, please contact admin"
    exit 1
else
    echo "[ ${GREEN}INFO${NC} ] /usr/lib/systemd/system/docker.service is setup"
fi

echo ""
# Install Kubernetes
if [ ! -f /etc/yum/repos.d/kubernetes.repo ]; then
    echo "[ ${BLUE}WARN${NC} ] Creating kubernetes.repo"
    mkdir -p /etc/yum/repos.d
    cat << EOF > /etc/yum/repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
else
    echo "[ ${GREEN}INFO${NC} ] kubernetes.repo already exists"
fi

# Install kubeadm
if [ -x "$(command -v kubeadm)" ]; then
    echo "[ ${GREEN}INFO${NC} ] kubeadm already installed"
    echo "[ ${GREEN}INFO${NC} ] ${BLUE}`kubeadm version`${NC}"
else
    echo "[ ${BLUE}WARN${NC} ] Installing kubeadm"
    yum -y install kubelet-${KUBELET} kubernetes-cni-${CNI} kubectl-${KUBECTL} kubeadm-${KUBEADM}
    systemctl enable kubelet
fi

if [ ! -f /etc/systemd/system/kubelet.service ]; then
    echo "[ ${RED}ERROR${NC} ] kubeadm installation failed, please contact admin"
    exit 1
else
    echo "[ ${GREEN}INFO${NC} ] /etc/systemd/system/kubelet.service is setup "
fi

echo ""
iptables_bridge_value=$(cat /proc/sys/net/bridge/bridge-nf-call-ip6tables)
if [ $iptables_bridge_value = 0 ]; then
    echo "[ ${BLUE}WARN${NC} ] Updating ip6tables_bridge_value"
    mkdir -p /proc/sys/net/bridge
    echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
else
    echo "[ ${GREEN}INFO${NC} ] ip6tables_bridge_value already set "
fi

docker_driver=`docker info|grep -i cgroup| awk {'print $3'}`
echo "[ ${GREEN}INFO${NC} ] docker Cgroup Driver: $docker_driver"
if [ ! -f /etc/systemd/system/kubelet.service.d/10-kubeadm.conf ]; then
    echo "[ ${RED}ERROR${NC} ] kubeadm installation failed, please contact admin"
    exit 1
else
    kube_driver_flag=`grep $docker_driver /etc/systemd/system/kubelet.service.d/10-kubeadm.conf|grep -v grep|wc -l`
    if [ "$docker_driver" == "cgroupfs" ]; then
        if [ "$kube_driver_flag" = 0 ]; then
            echo "[ ${BLUE}WARN${NC} ] Updating Cgroup Driver"
            sed -i 's/systemd/cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
        else
            echo "[ ${GREEN}INFO${NC} ] cgroup Drivers are matching: $docker_driver"
        fi
    fi

    if [ "$docker_driver" == "systemd" ]; then
        if [ "$kube_driver_flag" = 0 ]; then
            echo "[ ${BLUE}WARN${NC} ] Updating systemd Driver"
            sed -i 's#Environment="KUBELET_KUBECONFIG_ARGS=-.*#Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true --cgroup-driver=systemd"#g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
        else
            echo "[ ${GREEN}INFO${NC} ] cgroup Drivers are matching: $docker_driver"
        fi
    fi
fi

systemctl daemon-reload


# Check cfssl availability

if [ -x "$(command -v /usr/local/bin/cfssl)" ]; then
    echo "[ ${GREEN}INFO${NC} ] cfssl is installed already `cfssl version`"
    [[ ":PATH:" != *":/usr/local/bin:"* ]] && PATH="$PATH:/usr/local/bin"
else
    echo "[ ${BLUE}WARN${NC} ] Installing cfssl"
    wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
    wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
    wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
    echo "[ ${BLUE}WARN${NC} ] Copying binaries cfssl"
    chmod 755 cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64
    sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl
    sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
    sudo mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo

    [[ ":PATH:" != *":/usr/local/bin:"* ]] && PATH="$PATH:/usr/local/bin"
fi


echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Kubernetes Software setup completed                      ==="
echo "========================================================================="