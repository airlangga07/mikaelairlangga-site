#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

IMAGE_BASE="ghcr.io/airlangga07/mikaelairlangga-site"

# With no args, deploys the digest pinned in docker-compose.yml (or WEB_IMAGE from .env).
# Pass a semver tag or a full ref to deploy that instead — pinning by digest is preferred:
#   ./deploy.sh v1.1.0
#   ./deploy.sh ghcr.io/airlangga07/mikaelairlangga-site@sha256:<digest>
REF="${1:-}"
if [ -n "$REF" ]; then
  case "$REF" in
    *@sha256:* | */*) export WEB_IMAGE="$REF" ;;      # full ref or digest
    *)                export WEB_IMAGE="${IMAGE_BASE}:${REF}" ;;  # bare tag
  esac
fi

echo "==> Deploying ${WEB_IMAGE:-<digest pinned in docker-compose.yml>}"
docker compose pull web
docker compose up -d --remove-orphans

echo "==> Running image digest (pin this in docker-compose.yml or WEB_IMAGE for immutability):"
docker compose images web

echo "==> Deploy complete."
docker compose ps
