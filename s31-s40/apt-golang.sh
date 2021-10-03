#!/bin/bash

add-apt-repository --yes ppa:gophers/archive

apt-get --yes update

apt-get --yes --autoremove install golang
