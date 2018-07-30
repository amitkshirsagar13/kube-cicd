# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

Enable ssh on hosts:
Primary Master:
```
ssh-keygen -t rsa
```

Copy Output of Below:
```
cat ~/.ssh/id_rsa.pub
```
Paste to Below (Other Masters):
```
vi ~/.ssh/authorized_keys

sudo yum -y install policycoreutils-python

sudo semanage fcontext -a -t ssh_home_t "~/.ssh/authorized_keys"
ssh amit_kshirsagar_13@k8m2 "hostname -i && hostname -s && hostname -d && hostname -A"

sudo semanage fcontext -a -t ssh_home_t "~/.ssh/authorized_keys"
ssh amit_kshirsagar_13@k8m3 "hostname -i && hostname -s && hostname -d && hostname -A"
```


Install git first to start further installation

```
sudo su -
yum -y install git p7zip curl wget
git clone https://github.com/amitkshirsagar13/kube-cicd.git
mkdir -p /root/bin
curl -Ls https://raw.githubusercontent.com/amitkshirsagar13/kube-server/master/minikube/deploy.sh |sed -e 's/\r$//' | sh

cd kube-cicd/k8s/bin
chmod 777 -R /root
chmod 755 *
ls -l

cd ../.. && git reset --hard && git pull && cd k8s/bin && chmod 755 * && ls -l


yum install -y cockpit cockpit-packagekit cockpit-docker cockpit-machines cockpit-ostree cockpit-selinux cockpit-kubernetes 
systemctl enable --now cockpit

sudo vi /etc/ssh/sshd_config

sudo service sshd reload
sudo passwd

```
Add hosts entry as below:
IPADDRESS cockpit.k8m.k8cluster.io echoserver.dev.gce.k8m.k8cluster.io sechoserver.dev.gce.k8m.k8cluster.io cafe.dev.gce.k8m.k8cluster.io tea.dev.gce.k8m.k8cluster.io test.dev.gce.k8m.k8cluster.io

Test cluster:
