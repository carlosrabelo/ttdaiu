#!/bin/bash

echo "deb https://mega.nz/linux/MEGAsync/xUbuntu_18.04/ ./" > /etc/apt/sources.list.d/megasync.list

curl https://mega.nz/linux/MEGAsync/xUbuntu_18.04/Release.key | apt-key add -

apt-get update

apt-get install --yes --autoremove megasync
