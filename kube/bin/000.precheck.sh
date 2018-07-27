# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/sh

isRoot.sh

001.disableSELinux.sh
002.enableFirewallBridge.sh
003.disableswap.sh

packageManagement.sh
004.installDocker.sh
005.installKubernetes.sh
030.installNGINX.sh
