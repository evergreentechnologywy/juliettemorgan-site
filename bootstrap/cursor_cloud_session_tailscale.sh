#!/usr/bin/env bash
set -euo pipefail

# Fallback Cursor Cloud Tailscale join (same secret, inline up).
TS_SOCKET="${TS_SOCKET:-/var/run/tailscale/tailscaled.sock}"
TS_STATE="${TS_STATE:-/var/lib/tailscale/tailscaled.state}"
HOSTNAME_VALUE="${FLEET_HOSTNAME:-${HOSTNAME:-$(hostname -s)}}"

: "${TAILSCALE_AUTH_KEY:?TAILSCALE_AUTH_KEY must be set}"

if ! command -v tailscale >/dev/null 2>&1; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi

sudo mkdir -p /var/run/tailscale /var/lib/tailscale

if ! tailscale --socket="$TS_SOCKET" debug prefs >/dev/null 2>&1; then
  sudo bash -c "tailscaled --tun=userspace-networking --state='$TS_STATE' --socket='$TS_SOCKET' >>/tmp/tailscaled.log 2>&1" &
  for _ in $(seq 1 30); do
    tailscale --socket="$TS_SOCKET" debug prefs >/dev/null 2>&1 && break
    sleep 1
  done
fi

sudo tailscale --socket="$TS_SOCKET" up \
  --auth-key="$TAILSCALE_AUTH_KEY" \
  --hostname="$HOSTNAME_VALUE" \
  --ssh \
  --accept-routes

tailscale --socket="$TS_SOCKET" status
