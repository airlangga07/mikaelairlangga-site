#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

TAG="${1:-latest}"

echo "==> Deploying ghcr.io/airlangga07/mikaelairlangga-site:${TAG}"

export WEB_TAG="$TAG"
docker compose pull web
docker compose up -d --remove-orphans

echo "==> Deploy complete."
docker compose ps
