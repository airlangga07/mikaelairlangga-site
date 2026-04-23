#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }

cleanup() {
  docker compose -f docker-compose.yml down --remove-orphans -t 5 >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "==> Starting containers (web only)..."
# Start only the web container — cloudflared needs a real token
docker compose up -d web >/dev/null 2>&1

echo "==> Waiting for nginx..."
for i in $(seq 1 20); do
  if curl -sf http://localhost:3000/healthz >/dev/null 2>&1; then break; fi
  sleep 0.5
done

echo ""
echo "==> Tests"

# 1. healthz returns 200
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/healthz)
[[ "$STATUS" == "200" ]] && pass "GET /healthz → 200" || fail "GET /healthz → $STATUS (expected 200)"

# 2. healthz body is {"status":"ok"}
BODY=$(curl -s http://localhost:3000/healthz)
[[ "$BODY" == '{"status":"ok"}' ]] && pass "GET /healthz body = {\"status\":\"ok\"}" || fail "GET /healthz body = '$BODY'"

# 3. healthz Content-Type is application/json
CT=$(curl -sI http://localhost:3000/healthz | grep -i content-type | tr -d '\r')
[[ "$CT" == *"application/json"* ]] && pass "GET /healthz Content-Type includes application/json" || fail "GET /healthz Content-Type: '$CT'"

# 4. root returns 200
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/)
[[ "$STATUS" == "200" ]] && pass "GET / → 200" || fail "GET / → $STATUS (expected 200)"

# 5. root body contains expected title
BODY=$(curl -s http://localhost:3000/)
[[ "$BODY" == *"Mikael Airlangga"* ]] && pass "GET / body contains 'Mikael Airlangga'" || fail "GET / body missing 'Mikael Airlangga'"

# 6. unknown path returns 404
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/does-not-exist)
[[ "$STATUS" == "404" ]] && pass "GET /does-not-exist → 404" || fail "GET /does-not-exist → $STATUS (expected 404)"

echo ""
echo "==> Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
