# Uptime Monitoring

Monitor: `https://mikaelairlangga.com/healthz` → must return `{"status":"ok"}` with HTTP 200.

## UptimeRobot (free tier, recommended)

1. Go to https://uptimerobot.com → **Add New Monitor**
2. Monitor Type: **HTTPS**
3. Friendly Name: `mikaelairlangga.com`
4. URL: `https://mikaelairlangga.com/healthz`
5. Monitoring Interval: **5 minutes**
6. Alert Contacts: add your email → **Create Monitor**

Free tier gives 50 monitors at 5-min intervals.

## BetterStack (alternative)

1. Go to https://betterstack.com/uptime → **New monitor**
2. URL: `https://mikaelairlangga.com/healthz`
3. Check frequency: **3 minutes** (free tier)
4. Expected status: 200
5. Add email alert → **Save**

## What gets monitored

The `/healthz` endpoint is served directly by nginx with no application logic:

```
location /healthz {
    return 200 '{"status":"ok"}';
}
```

If this fails, the nginx container is down — which means the Cloudflare Tunnel has nothing to forward to. The tunnel itself does not need monitoring (Cloudflare handles its own health).
