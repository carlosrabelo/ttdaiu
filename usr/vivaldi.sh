#!/bin/bash

echo echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vivaldi.list

wget -qO- http://repo.vivaldi.com/stable/linux_signing_key.pub | apt-key add -

apt-get update

apt-get install vivaldi-stable
