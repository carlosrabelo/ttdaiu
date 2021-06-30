#!/bin/bash

apt-get install --yes --autoremove $(grep -vE "^\s*#" s01.apt | tr "\n" " ")
