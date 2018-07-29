# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh

echo echo "[ ${GREEN}INFO${NC} ] Checking if user is root"

if [[ $EUID -ne 0 ]]; then
    echo echo "[ ${RED}ERROR${NC} ] This script must be run as root" 
    exit 1
else
    echo echo "[ ${GREEN}INFO${NC} ] Running setup as Root"
fi
echo ""
