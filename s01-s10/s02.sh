#!/bin/bash

apt-get --yes --autoremove install $(grep -vE "^\s*#" s02.apt | tr "\n" " ")
