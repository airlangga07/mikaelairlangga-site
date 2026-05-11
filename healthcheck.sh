#!/bin/bash

source "$(dirname "$0")/.env"

HEALTHZ_URL="https://mikaelairlangga.com/healthz"
FLAG_FILE="/tmp/site_down_notified"

response=$(curl -s -o /tmp/healthz_body -w "%{http_code}" --max-time 10 "$HEALTHZ_URL" 2>/dev/null)
body=$(cat /tmp/healthz_body)

if [ "$response" != "200" ] || [ "$body" != '{"status":"ok"}' ]; then
  if [ ! -f "$FLAG_FILE" ]; then
    touch "$FLAG_FILE"
    curl -s -X POST "$DISCORD_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "{\"content\": \"🚨 **mikaelairlangga.com is DOWN**\\nHealth check failed at $(date -u '+%Y-%m-%d %H:%M UTC')\\nHTTP status: $response\\nResponse: $body\"}"
  fi
else
  if [ -f "$FLAG_FILE" ]; then
    rm "$FLAG_FILE"
    curl -s -X POST "$DISCORD_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "{\"content\": \"✅ **mikaelairlangga.com is back UP**\\nRecovered at $(date -u '+%Y-%m-%d %H:%M UTC')\"}"
  fi
fi
