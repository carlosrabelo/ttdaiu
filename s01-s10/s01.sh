#!/bin/bash

apt-get --yes --autoremove install $(grep -vE "^\s*#" s01.apt | tr "\n" " ")
