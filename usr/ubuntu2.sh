#!/bin/bash

apt-get install --yes --autoremove $(grep -vE "^\s*#" ubuntu2.apt | tr "\n" " ")
