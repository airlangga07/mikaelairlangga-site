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

echo "==> Deploying ${WEB_IMAGE:-<WEB_IMAGE from .env / default in docker-compose.yml>}"
docker compose pull web
docker compose up -d --remove-orphans

# Resolve the running image to an immutable digest and persist it as the .env pin, so a
# later plain `docker compose up -d` (or a reboot) stays on exactly this build rather than
# reverting to a stale WEB_IMAGE or the compose default.
ENV_FILE="$SCRIPT_DIR/.env"
DIGEST_REF="$(docker inspect --format '{{index .RepoDigests 0}}' "$(docker compose images -q web)" 2>/dev/null || true)"
if [ -n "$DIGEST_REF" ] && [ -f "$ENV_FILE" ]; then
  if grep -q '^WEB_IMAGE=' "$ENV_FILE"; then
    sed -i "s|^WEB_IMAGE=.*|WEB_IMAGE=${DIGEST_REF}|" "$ENV_FILE"
  else
    printf '\nWEB_IMAGE=%s\n' "$DIGEST_REF" >> "$ENV_FILE"
  fi
  echo "==> Pinned WEB_IMAGE=${DIGEST_REF} in .env"
else
  echo "==> Running image digest (pin this in .env as WEB_IMAGE for immutability):"
  docker compose images web
fi

echo "==> Deploy complete."
docker compose ps
