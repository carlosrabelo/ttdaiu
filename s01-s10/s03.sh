#!/bin/bash

apt --yes --autoremove install linux-headers-$(uname -r)

apt --yes --autoremove install $(grep -vE "^\s*#" s03.apt | tr "\n" " ")
