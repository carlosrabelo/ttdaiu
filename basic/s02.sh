#!/bin/bash

apt install --yes --autoremove $(grep -vE "^\s*#" s02.apt | tr "\n" " ")
