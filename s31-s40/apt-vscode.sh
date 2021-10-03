#!/bin/bash

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | apt-key add -

echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

apt-get --yes update

apt-get --yes --autoremove install apt-transport-https

apt-get --yes --autoremove install  code
