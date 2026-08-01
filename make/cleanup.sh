#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning temporary files..."
find . -name "*.retry" -delete 2>/dev/null || true
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true
