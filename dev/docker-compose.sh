#!/bin/bash

base=https://github.com/docker/compose/releases/download/1.24.0

curl -L $base/docker-compose-$(uname -s)-$(uname -m) >/tmp/docker-compose

install /tmp/docker-compose /usr/local/bin/docker-compose
