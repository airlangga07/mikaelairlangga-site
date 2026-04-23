# CLAUDE.md — mikaelairlangga-site

## What this is
Personal static site for mikaelairlangga.com. Served by nginx in Docker, tunnelled to the internet via Cloudflare. Runs on a Raspberry Pi 5. No backend, no database.

## Stack
- nginx:alpine — serves static files from `./site/`, port 3000
- cloudflare/cloudflared — tunnel sidecar
- Docker Compose — only runtime
- Shell — deploy script and tests

## Hard rules
- No database, no backend server, no build step
- All Docker images must support linux/arm64 (Pi is arm64)
- Port 3000 is fixed — cloudflared expects `http://web:3000`
- `/healthz` must return `{"status":"ok"}` with `Content-Type: application/json` — never remove it
- Never commit `.env`

## Running locally
```sh
docker compose up -d
curl http://localhost:3000
curl http://localhost:3000/healthz
docker compose down
```

## Tests
```sh
bash tests/test.sh
```
Spins up containers, curls endpoints, asserts responses, tears down.

## Deploying (on the Pi)
```sh
cd ~/apps/mikaelairlangga-site
git pull
./deploy.sh
```
SSH config and Pi details → Notion Infra DB: https://www.notion.so/c9728de99aba401b8d3b70688b561bfb

## Infra reference
Before touching docker-compose, .env, or anything network-related — check the Notion Infrastructure & Services DB above for current Pi status, SSH key location, and active services.
