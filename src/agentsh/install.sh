#!/bin/sh
# POSIX bootstrap for the agentsh feature installer.
#
# The main installer (install-main.sh) is written in Bash, but minimal base
# images such as Alpine ship without Bash. A `#!/bin/bash` entry script would
# fail with "not found" before it could install anything. This bootstrap is
# kept POSIX-compatible (runs under busybox ash / dash), ensures Bash is
# available, then hands off to install-main.sh.
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v bash >/dev/null 2>&1; then
    echo "[agentsh feature] Installing bash (required by the installer)"
    if command -v apk >/dev/null 2>&1; then
        apk add --no-cache bash >/dev/null
    elif command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get install -y --no-install-recommends bash
    else
        echo "[agentsh feature] ERROR: bash is required but no supported package manager (apk/apt-get) was found" >&2
        exit 1
    fi
fi

exec bash "${SCRIPT_DIR}/install-main.sh" "$@"
