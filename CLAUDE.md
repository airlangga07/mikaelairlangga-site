# CLAUDE.md — mikaelairlangga-site

## What this is
Personal static site for mikaelairlangga.com. Served by nginx in Docker, tunnelled to the internet via Cloudflare. Runs on a **Raspberry Pi 3B+ (`rpi3`)**, the homelab production edge — migrated from the Pi 5 on 2026-06-30. No backend, no database.

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
The site is baked into a **private GHCR image by CI** — it is not `git pull`ed onto the host.
On `rpi3` the running image is **pinned by digest** in `docker-compose.yml`; deploy by updating
the digest (or a semver tag) deliberately, then:
```sh
cd ~/apps/mikaelairlangga-site
docker compose pull web
docker compose up -d web        # verify, then:
docker compose up -d cloudflared
```
Host / SSH / infra details live in the **Obsidian vault** → Infrastructure & Services →
`mikaelairlangga-site` (this replaced the old Notion Infra DB).

## Infra reference
Before touching docker-compose, .env, or anything network-related — check the **Obsidian vault**
(Infrastructure & Services → `mikaelairlangga-site`, and the `Mikael Airlangga Site` project
notes) for current host status, SSH access, and active services. (Replaced the old Notion DB.)
