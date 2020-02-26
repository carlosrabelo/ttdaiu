#!/bin/bash

apt install --yes --autoremove $(grep -vE "^\s*#" ubuntu-dev-2.apt | tr "\n" " ")
