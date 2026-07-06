# mikaelairlangga-site — Project Spec

## Overview

Personal static website for **mikaelairlangga.com**, self-hosted on a **Raspberry Pi 3B+ (`rpi3`)** and made public via Cloudflare Tunnel. No database. No backend logic. Pure static HTML/CSS/JS served by nginx. (Migrated from the Pi 5 to the 3B+ production edge on 2026-06-30.)

## Goals

- Ultra-simple: one nginx container + one cloudflared sidecar
- Zero ongoing cost (self-hosted on Pi)
- HTTPS via Cloudflare (no cert management needed)
- `/healthz` endpoint for uptime monitoring

## Stack

| Component        | Choice                     |
|------------------|----------------------------|
| Web server       | nginx:alpine               |
| Tunnel           | cloudflare/cloudflared     |
| Container runtime| Docker Compose             |
| Host             | Raspberry Pi 3B+ (`rpi3`, arm64) |

## Architecture

```
Internet → Cloudflare Tunnel → cloudflared → nginx (port 3000) → static files
```

## Containers

| Service        | Image                                          | Internal port |
|----------------|------------------------------------------------|---------------|
| `web`          | `ghcr.io/airlangga07/mikaelairlangga-site` (built `FROM nginx:alpine`) | 3000          |
| `cloudflared`  | cloudflare/cloudflared                         | —             |

The static site is **baked into** the `web` image at build time (see `Dockerfile`) — CI on
GitHub Actions builds and pushes it to GHCR; the Pi pulls the image (it does not build).

## Endpoints

| Path       | Response                              |
|------------|---------------------------------------|
| `/`        | Landing page HTML                     |
| `/healthz` | `{"status":"ok"}` (application/json)  |

## Environment Variables

| Variable                  | Description                                      |
|---------------------------|--------------------------------------------------|
| `CLOUDFLARE_TUNNEL_TOKEN` | Token from Cloudflare Zero Trust dashboard       |

## Repository Structure

```
mikaelairlangga-site/
├── .env                    # not committed — secrets (CLOUDFLARE_TUNNEL_TOKEN, DISCORD_WEBHOOK_URL)
├── .env.example            # committed — documents required vars
├── .gitignore
├── CLAUDE.md               # instructions for Claude Code
├── PROJECT_SPEC.md         # this file
├── Dockerfile              # bakes ./site into nginx:alpine
├── deploy.sh               # pull the GHCR image + docker compose up -d on the Pi
├── docker-compose.yml      # web (GHCR image) + cloudflared sidecar
├── healthcheck.sh          # off-box uptime check (Discord webhook) — runs on rpi5, not here
├── .github/workflows/
│   └── ci.yml              # build & push multi-arch image to ghcr.io on push/tag
├── docs/
│   └── uptime-monitoring.md
├── nginx/
│   └── default.conf        # nginx: serves ./site, healthz stub
├── site/
│   └── index.html          # landing page
└── tests/
    └── test.sh             # integration tests (spin up, curl, tear down)
```

## Deployment (on the Pi)

The site ships as a **GHCR image**, not source — CI builds it on push to `main` (`sha-<shortsha>`)
and on `vX.Y.Z` tags. On `rpi3` the running image is **pinned by digest** — via `WEB_IMAGE` in
`.env` or the default in `docker-compose.yml`. Deploy a specific build with `deploy.sh`, which
sets `WEB_IMAGE`, pulls, recreates, and prints the running digest so you can pin it:

```sh
cd ~/apps/mikaelairlangga-site
./deploy.sh v1.1.0     # a semver tag, or a full ...@sha256:<digest> ref (digest preferred)
# by hand: docker compose pull web && docker compose up -d web && docker compose up -d cloudflared
```

Pinning by **digest** (not a moving tag) keeps prod immutable; bump the pinned default in
`docker-compose.yml` (or set `WEB_IMAGE`) deliberately per release. First-time setup only needs
`.env` (from `.env.example`) with `CLOUDFLARE_TUNNEL_TOKEN` and `DISCORD_WEBHOOK_URL`, plus GHCR
pull auth in `~/.docker/config.json`.

## Verification

```sh
curl https://mikaelairlangga.com           # returns HTML
curl https://mikaelairlangga.com/healthz   # returns {"status":"ok"}
ssh rpi3 "docker compose -f ~/apps/mikaelairlangga-site/docker-compose.yml ps"
```
