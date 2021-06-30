#!/bin/bash

apt install --yes --autoremove $(grep -vE "^\s*#" s04.apt | tr "\n" " ")
