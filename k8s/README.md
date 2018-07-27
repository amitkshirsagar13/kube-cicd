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
yum -y install git
git clone https://github.com/amitkshirsagar13/kube-cicd.git
cd kube-cicd/k8s/bin
chmod 777 -R /root
chmod 755 *
ls -l

cd ../.. && git reset --hard && git pull && cd k8s/bin && chmod 755 * && ls -l

sudo vi /etc/ssh/sshd_config

sudo passwd

sudo service sshd reload
```