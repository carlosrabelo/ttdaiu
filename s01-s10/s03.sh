#!/bin/bash

apt-get --yes --autoremove install $(grep -vE "^\s*#" s03.apt | tr "\n" " ")
