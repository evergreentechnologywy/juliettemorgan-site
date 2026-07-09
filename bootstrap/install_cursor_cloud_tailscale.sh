#!/usr/bin/env bash
set -euo pipefail

# Cursor Cloud session bootstrap: join tailnet using injected runtime secret.
if [ -z "${TAILSCALE_AUTH_KEY:-}" ]; then
  echo "ERROR: TAILSCALE_AUTH_KEY is not set (Cursor Cloud runtime secret)" >&2
  exit 1
fi

export TS_AUTHKEY="$TAILSCALE_AUTH_KEY"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/start_tailscale_cloud.sh" "$@"
