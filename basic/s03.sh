#!/bin/bash

apt install --yes --autoremove $(grep -vE "^\s*#" s03.apt | tr "\n" " ")
