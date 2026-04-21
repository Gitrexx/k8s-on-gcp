#!/usr/bin/env bash
# One-time setup: configure gcloud and kubectl context for the GKE cluster.
# Usage: ./scripts/bootstrap.sh <project-id> <cluster-name> <zone>
set -euo pipefail

PROJECT_ID="${1:?usage: $0 <project-id> <cluster-name> <zone>}"
CLUSTER_NAME="${2:?usage: $0 <project-id> <cluster-name> <zone>}"
ZONE="${3:?usage: $0 <project-id> <cluster-name> <zone>}"

echo "==> Authenticating with gcloud..."
gcloud auth login

echo "==> Setting project to ${PROJECT_ID}..."
gcloud config set project "${PROJECT_ID}"

echo "==> Fetching GKE credentials for ${CLUSTER_NAME} in ${ZONE}..."
gcloud container clusters get-credentials "${CLUSTER_NAME}" --zone "${ZONE}" --project "${PROJECT_ID}"

echo "==> Current context:"
kubectl config current-context

echo "==> Done. You can now run: kustomize build cluster/ | kubectl apply -f -"
