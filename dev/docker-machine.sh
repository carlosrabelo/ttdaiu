#!/bin/bash

base=https://github.com/docker/machine/releases/download/v0.16.1

curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine

install /tmp/docker-machine /usr/local/bin/docker-machine
