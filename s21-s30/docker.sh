#/bin/bash

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" > /etc/apt/sources.list.d/docker.list

apt-get --yes update

apt-get --yes --autoremove install apt-transport-https ca-certificates curl software-properties-common

apt-get --yes --autoremove install docker-ce
