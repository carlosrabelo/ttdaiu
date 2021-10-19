#/bin/bash

echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

apt-get update

apt-get --yes --autoremove install google-chrome-stable
