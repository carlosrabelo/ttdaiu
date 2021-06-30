#!/bin/bash

echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | apt-key add -

apt-get update

apt-get install --yes --autoremove apt-transport-https
apt-get install --yes --autoremove code
