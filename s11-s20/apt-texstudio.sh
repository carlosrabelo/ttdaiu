#!/bin/bash

apt-get install --yes --autoremove $(grep -vE "^\s*#" apt-texstudio.apt | tr "\n" " ")
