#!/usr/bin/env bash
set -euo pipefail

# Evergreen fleet: Tailscale bootstrap for Cursor cloud agents (no systemd).
TS_SOCKET="${TS_SOCKET:-/var/run/tailscale/tailscaled.sock}"
TS_STATE="${TS_STATE:-/var/lib/tailscale/tailscaled.state}"
TS_PIDFILE="${TS_PIDFILE:-/var/run/tailscale/tailscaled.pid}"
HOSTNAME_VALUE="${FLEET_HOSTNAME:-${HOSTNAME:-$(hostname -s)}}"

read_authkey() {
  if [ -n "${TS_AUTHKEY:-}" ]; then
    printf '%s' "$TS_AUTHKEY"
    return 0
  fi
  if [ -n "${TAILSCALE_AUTHKEY:-}" ]; then
    printf '%s' "$TAILSCALE_AUTHKEY"
    return 0
  fi
  local f
  for f in \
    /etc/evergreen/tailscale.authkey \
    "${HOME}/.config/evergreen/tailscale.authkey" \
    "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.tailscale.authkey"; do
    if [ -f "$f" ]; then
      tr -d '[:space:]' <"$f"
      return 0
    fi
  done
  return 1
}

tailscaled_ready() {
  tailscale --socket="$TS_SOCKET" debug prefs >/dev/null 2>&1
}

ensure_tun() {
  if [ -e /dev/net/tun ]; then
    return 0
  fi
  sudo mkdir -p /dev/net
  sudo mknod /dev/net/tun c 10 200
  sudo chmod 0666 /dev/net/tun
}

ensure_tailscale_installed() {
  if command -v tailscale >/dev/null 2>&1; then
    return 0
  fi
  curl -fsSL https://tailscale.com/install.sh | sh
}

start_tailscaled() {
  ensure_tun
  sudo mkdir -p /var/run/tailscale /var/lib/tailscale

  if tailscaled_ready; then
    return 0
  fi

  if [ -f "$TS_PIDFILE" ]; then
    local old_pid
    old_pid="$(cat "$TS_PIDFILE" 2>/dev/null || true)"
    if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null && tailscaled_ready; then
      return 0
    fi
  fi

  # Cloud-agent VMs often lack a working kernel TUN; userspace mode is reliable.
  sudo bash -c "tailscaled --tun=userspace-networking --state='$TS_STATE' --socket='$TS_SOCKET' >>/tmp/tailscaled.log 2>&1" &
  echo "$!" | sudo tee "$TS_PIDFILE" >/dev/null

  for _ in $(seq 1 30); do
    if tailscaled_ready; then
      return 0
    fi
    sleep 1
  done

  echo "ERROR: tailscaled did not become ready" >&2
  tail -20 /tmp/tailscaled.log >&2 || true
  exit 1
}

main() {
  ensure_tailscale_installed
  start_tailscaled

  local authkey
  if ! authkey="$(read_authkey 2>/dev/null)" || [ -z "$authkey" ]; then
    echo "ERROR: no Tailscale auth key; set TS_AUTHKEY, TAILSCALE_AUTHKEY, or bootstrap/.tailscale.authkey" >&2
    exit 1
  fi

  local up_args=(--hostname="$HOSTNAME_VALUE" --ssh --accept-routes --auth-key="$authkey")

  sudo tailscale --socket="$TS_SOCKET" up "${up_args[@]}"
  tailscale --socket="$TS_SOCKET" status
}

main "$@"
