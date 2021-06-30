#!/bin/bash

apt-get install --yes --autoremove $(grep -vE "^\s*#" texstudio.apt | tr "\n" " ")
