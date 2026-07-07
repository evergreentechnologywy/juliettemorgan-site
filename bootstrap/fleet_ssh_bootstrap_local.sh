#!/usr/bin/env bash
set -euo pipefail

# Evergreen fleet: enable and verify Tailscale SSH on this node.
TS_SOCKET="${TS_SOCKET:-/var/run/tailscale/tailscaled.sock}"

if ! command -v tailscale >/dev/null 2>&1; then
  echo "ERROR: tailscale not installed; run bootstrap/start_tailscale_cloud.sh first" >&2
  exit 1
fi

if ! tailscale --socket="$TS_SOCKET" debug prefs >/dev/null 2>&1; then
  echo "ERROR: tailscaled not running; run bootstrap/start_tailscale_cloud.sh first" >&2
  exit 1
fi

sudo tailscale --socket="$TS_SOCKET" set --ssh=true 2>/dev/null || true

if ! tailscale --socket="$TS_SOCKET" debug prefs 2>/dev/null | grep -q 'RunSSH.*true'; then
  echo "ERROR: RunSSH preference is not true" >&2
  tailscale --socket="$TS_SOCKET" debug prefs >&2 || true
  exit 1
fi

ip="$(tailscale --socket="$TS_SOCKET" ip -4 2>/dev/null || true)"
if [ -z "$ip" ]; then
  echo "ERROR: tailscale has no IPv4 address; node may not be authenticated" >&2
  exit 1
fi

if ss -tlnp 2>/dev/null | grep -q ':22'; then
  echo "OpenSSH listening on :22 (Tailscale SSH also enabled)"
else
  echo "Tailscale SSH-only (no listener on :22)"
fi

echo "Fleet SSH ready: $(hostname -s) ${ip}"
