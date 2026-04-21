# k8s-on-gcp

## Project Goal

A personal GKE cluster used as a development and learning ground for Kubernetes. Infrastructure is managed as code using **Kustomize** for manifest management and **GitHub Actions** for automated deployment (GitOps-lite pattern).

Each application lives in its own namespace and folder. Adding a new app means adding a new folder under `apps/` and a matching workflow file — nothing else changes.

---

## Cluster

- **Provider**: Google Cloud GKE
- **Purpose**: Dev / learning — single cluster
- **Namespace strategy**: One namespace per app/service

---

## Repository Structure

```
k8s-on-gcp/
├── .github/
│   └── workflows/
│       ├── deploy-mlflow.yml    # Deploys mlflow only when apps/mlflow/** changes
│       └── validate.yml         # Dry-run validation on PRs (auto-detects changed apps)
│
├── apps/
│   └── mlflow/                  # MLflow tracking server
│       ├── base/                # Canonical manifests (namespace, deployment, service)
│       └── overlays/
│           └── dev/             # GKE-specific patches and image tags
│
├── cluster/
│   └── kustomization.yaml       # Aggregates all apps (used for local reference)
│
├── scripts/
│   ├── bootstrap.sh             # One-time cluster setup (gcloud, kubectl context)
│   └── validate.sh              # Local dry-run helper
│
└── CLAUDE.md                    # This file
```

---

## Deployment Trigger Strategy

Each app has its **own deploy workflow** (e.g. `deploy-mlflow.yml`) with a `paths` filter scoped to that app:

```
on:
  push:
    branches: [main]
    paths:
      - "apps/mlflow/**"
```

This means:
- Changing mlflow manifests → only `deploy-mlflow.yml` fires → only mlflow is redeployed.
- Other apps are completely untouched.
- `validate.yml` on PRs auto-detects which apps changed and validates only those overlays.

---

## Adding a New App

1. Create `apps/<app-name>/base/` with `kustomization.yaml`, `namespace.yaml`, `deployment.yaml`, `service.yaml`.
2. Create `apps/<app-name>/overlays/dev/kustomization.yaml` with any GKE-specific patches.
3. Add a resource entry to `cluster/kustomization.yaml`.
4. Copy `.github/workflows/deploy-mlflow.yml` → `.github/workflows/deploy-<app-name>.yml` and update the `paths` filter, deployment name, and namespace throughout.
5. Open a PR — `validate.yml` will dry-run the new app automatically.

---

## GitHub Actions Secrets Required

| Secret | Description |
|---|---|
| `GCP_PROJECT_ID` | GCP project ID |
| `GCP_SA_KEY` | Service account JSON key with GKE access |
| `GKE_CLUSTER_NAME` | Name of the GKE cluster |
| `GKE_CLUSTER_ZONE` | Zone/region of the GKE cluster |

---

## Current Apps

| App | Namespace | Workflow |
|---|---|---|
| mlflow | mlflow | `deploy-mlflow.yml` |
