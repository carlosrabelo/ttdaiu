#!/bin/bash

apt-get install --yes --autoremove $(grep -vE "^\s*#" s02.apt | tr "\n" " ")
