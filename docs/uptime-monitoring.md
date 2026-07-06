# Uptime Monitoring

Monitor: `https://mikaelairlangga.com/healthz` → must return `{"status":"ok"}` with HTTP 200.

## Current setup: self-hosted, off-box (Discord webhook)

Monitoring is **self-hosted** (zero external SaaS) via [`healthcheck.sh`](../healthcheck.sh),
run on a schedule. It is deliberately kept **off the production edge** so the box serving the
site is not the only thing that can detect its own outage:

- **Where it runs:** `~/apps/site-monitor/healthcheck.sh` on **`rpi5`** (the dev/QA box), *not*
  on `rpi3` (the production edge that runs the site).
- **Schedule:** cron every 5 minutes (`*/5 * * * *`).
- **Endpoint:** the public `https://mikaelairlangga.com/healthz` (so it exercises the whole
  path — Cloudflare Tunnel → `cloudflared` → nginx — not just the local origin).
- **Alerting:** posts to a Discord webhook (`DISCORD_WEBHOOK_URL` in the monitor's `.env`) on
  **down** and again on **recovery**.
- **Deduplication:** a flag file (`/tmp/site_down_notified`) so you get one alert per outage,
  not one every 5 minutes.

If the check fails, the nginx container is down (or the tunnel can't reach it) — which means the
Cloudflare Tunnel has nothing to forward to. The tunnel itself does not need monitoring
(Cloudflare handles its own edge health).

## What gets monitored

The `/healthz` endpoint is served directly by nginx with no application logic:

```
location /healthz {
    access_log off;
    add_header Content-Type application/json;
    return 200 '{"status":"ok"}';
}
```

## Notes

- The monitor lives off-box because the RCA for the 2026-06 intermittent outages showed a
  host-network problem on the *former* host — a self-monitor on the same box would have gone
  down with it. See the Obsidian vault → Infrastructure & Services → `mikaelairlangga-site`
  for the full runbook and RCA.
- A future homelab observability stack (Prometheus + Grafana + `blackbox_exporter`) is planned
  to supersede this single cron with proper dashboards and alerting.
