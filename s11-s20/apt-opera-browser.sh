#!/bin/bash

echo "deb http://deb.opera.com/opera-stable/ stable non-free" >> /etc/apt/sources.list.d/opera.list

wget -qO- https://deb.opera.com/archive.key | apt-key add -

apt-get --yes update

apt-get --yes --autoremove install opera-stable
