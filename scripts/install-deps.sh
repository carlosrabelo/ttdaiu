#!/usr/bin/env bash
set -euo pipefail

echo "Installing dependencies..."

sudo apt update
sudo apt install -y ansible git sshpass
