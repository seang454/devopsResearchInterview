#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND_CONFIG="${BACKEND_CONFIG:-backend.gcs.hcl}"

for component in \
  "$ROOT_DIR/live/dev/asia-southeast1/gcp-vm"
do
  echo "Planning $component"
  cd "$component"
  terraform init -backend-config="$BACKEND_CONFIG"
  terraform plan
done
