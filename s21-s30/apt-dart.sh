#/bin/bash

curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list

apt-get --yes update

apt-get --yes --autoremove install apt-transport-https

apt-get --yes --autoremove install dart
