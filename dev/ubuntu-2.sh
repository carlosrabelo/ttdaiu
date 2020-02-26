#!/bin/bash

apt install --yes --autoremove $(grep -vE "^\s*#" ubuntu-2.apt | tr "\n" " ")
