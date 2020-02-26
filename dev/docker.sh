#/bin/bash

echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" > /etc/apt/sources.list.d/docker.list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt-get update

apt-get install --yes --autoremove apt-transport-https ca-certificates curl software-properties-common
apt-get install --yes --autoremove docker-ce
