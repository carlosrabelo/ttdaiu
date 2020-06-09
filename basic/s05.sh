#!/bin/bash

apt-get install --yes --autoremove $(grep -vE "^\s*#" s05.apt | tr "\n" " ")
