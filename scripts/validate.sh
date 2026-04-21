#!/usr/bin/env bash
# Local dry-run: build all kustomize overlays and validate output.
# Usage: ./scripts/validate.sh [--apply]
set -euo pipefail

DRY_RUN=true
if [[ "${1:-}" == "--apply" ]]; then
  DRY_RUN=false
fi

echo "==> Building cluster kustomization..."
kustomize build cluster/

if $DRY_RUN; then
  echo "==> Dry-run (server-side)..."
  kustomize build cluster/ | kubectl apply --dry-run=server -f -
else
  echo "==> Applying to cluster..."
  kustomize build cluster/ | kubectl apply -f -
fi

echo "==> Done."
