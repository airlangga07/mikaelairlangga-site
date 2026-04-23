# mikaelairlangga-site — Project Spec

## Overview

Personal static website for **mikaelairlangga.com**, self-hosted on a Raspberry Pi 5 and made public via Cloudflare Tunnel. No database. No backend logic. Pure static HTML/CSS/JS served by nginx.

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
| Host             | Raspberry Pi 5 (arm64)     |

## Architecture

```
Internet → Cloudflare Tunnel → cloudflared → nginx (port 3000) → static files
```

## Containers

| Service        | Image                      | Internal port |
|----------------|----------------------------|---------------|
| `web`          | nginx:alpine               | 3000          |
| `cloudflared`  | cloudflare/cloudflared     | —             |

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
├── .env                    # not committed — secrets
├── .env.example            # committed — documents required vars
├── .gitignore
├── CLAUDE.md               # instructions for Claude Code
├── PROJECT_SPEC.md         # this file
├── deploy.sh               # git pull + docker compose up -d on the Pi
├── docker-compose.yml
├── nginx/
│   └── default.conf        # nginx: serves ./site, healthz stub
├── site/
│   └── index.html          # landing page
└── tests/
    └── test.sh             # integration tests (spin up, curl, tear down)
```

## Deployment (on the Pi)

```sh
git clone git@github.com:airlangga07/mikaelairlangga-site.git ~/apps/mikaelairlangga-site
cd ~/apps/mikaelairlangga-site
cp .env.example .env
# fill in CLOUDFLARE_TUNNEL_TOKEN
./deploy.sh
```

## Verification

```sh
curl https://mikaelairlangga.com           # returns HTML
curl https://mikaelairlangga.com/healthz   # returns {"status":"ok"}
ssh rpi5 "docker compose -f ~/apps/mikaelairlangga-site/docker-compose.yml ps"
```
