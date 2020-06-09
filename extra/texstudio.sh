#!/bin/bash

apt install --yes --autoremove $(grep -vE "^\s*#" texstudio.apt | tr "\n" " ")
