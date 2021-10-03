#/bin/bash

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt-get --yes update

apt-get --yes --autoremove install apt-transport-https ca-certificates software-properties-common

apt-get --yes --autoremove install kubectl
