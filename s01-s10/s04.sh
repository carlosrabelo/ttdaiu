#!/bin/bash

apt-get --yes --autoremove install $(grep -vE "^\s*#" s04.apt | tr "\n" " ")
