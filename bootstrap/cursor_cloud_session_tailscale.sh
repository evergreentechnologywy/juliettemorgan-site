#!/usr/bin/env bash
set -euo pipefail

# Fallback Cursor Cloud Tailscale join (delegates to shared bootstrap).
: "${TAILSCALE_AUTH_KEY:?TAILSCALE_AUTH_KEY must be set}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/start_tailscale_cloud.sh" "$@"
