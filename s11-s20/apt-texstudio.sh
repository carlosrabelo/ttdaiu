#!/bin/bash

apt-get --yes --autoremove install $(grep -vE "^\s*#" apt-texstudio.apt | tr "\n" " ")
