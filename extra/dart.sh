#/bin/bash

curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list

curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

apt-get update

apt-get install --yes --autoremove apt-transport-https
apt-get install --yes --autoremove dart

