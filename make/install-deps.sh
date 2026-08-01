#!/usr/bin/env bash
set -euo pipefail

echo "Installing TTDAIU dependencies..."

# curl and rsync are required for local and remote execution
sudo apt-get update -q
sudo apt-get install -y curl rsync

echo ""
echo "Dependencies installed:"
echo "  curl  : $(curl --version | head -1)"
echo "  rsync : $(rsync --version | head -1)"
echo ""
echo "Done."
