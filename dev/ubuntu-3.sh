#!/bin/bash

apt install --yes --autoremove $(grep -vE "^\s*#" ubuntu-3.apt | tr "\n" " ")
