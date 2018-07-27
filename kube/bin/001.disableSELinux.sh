# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash

echo 'Disabling SELinux'

echo 'Check SELinux status';
selinuxenabled
if [ $? -ne 0 ]
then 
    echo "SELinux DISABLED"
else
    echo "SELinux ENABLED"
    setenforce 0
    sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
fi

