#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring git hooks path..."
git config core.hooksPath .githooks
chmod +x .githooks/*

echo "==> Done. Git hooks are now active from .githooks/"
