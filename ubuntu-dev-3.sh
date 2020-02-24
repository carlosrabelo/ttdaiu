#!/bin/bash

apt install --yes --autoremove $(grep -vE "^\s*#" ubuntu-dev-3.apt | tr "\n" " ")
