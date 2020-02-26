#!/bin/bash

echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -

apt-get update

apt-get install yarn
