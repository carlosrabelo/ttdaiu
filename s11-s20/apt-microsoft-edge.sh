#!/bin/bash

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg

install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/

echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-beta.list

rm /tmp/microsoft.gpg

apt-get --yes update

apt-get --yes --autoremove install microsoft-edge-beta
