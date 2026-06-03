#!/bin/bash
set -euo pipefail

INSTALL_ROOT="${AGENTSH_INSTALL_ROOT:-/usr/local/share/agentsh}"
SECURITY_FLOOR_PATH="${AGENTSH_SECURITY_FLOOR_PATH:-${INSTALL_ROOT}/security-floor.yaml}"
DEFAULT_POLICY_PATH="${AGENTSH_DEFAULT_POLICY_PATH:-/etc/agentsh/policy.yaml}"
# config.yaml is the authoritative file agentsh reads (default --config path).
# It carries the HTTP bind address, auth, and policies.dir/default settings.
SERVER_RUNTIME_CONFIG_PATH="${AGENTSH_SERVER_RUNTIME_CONFIG_PATH:-/etc/agentsh/config.yaml}"
MERGE_POLICY_PATH="${AGENTSH_MERGE_POLICY_PATH:-${INSTALL_ROOT}/merge-policy.py}"
RUNTIME_POLICY_PATH="${AGENTSH_RUNTIME_POLICY_PATH:-/run/agentsh/policy.yaml}"
PID_FILE="${AGENTSH_PID_FILE:-/run/agentsh/server.pid}"

# Feature options are only present as environment variables during install. The
# installer persists the runtime-relevant ones here so the entrypoint can honor
# them when the container starts (the option env vars are not available then).
FEATURE_ENV_PATH="${AGENTSH_FEATURE_ENV_PATH:-/etc/agentsh/feature.env}"
if [ -f "$FEATURE_ENV_PATH" ]; then
    # shellcheck disable=SC1090
    . "$FEATURE_ENV_PATH"
fi
POLICY_OVERLAY_PATH="${POLICYOVERLAYPATH:-.devcontainer/agentsh-policy.yaml}"

log() {
    echo "[agentsh startup] $*"
}

fail() {
    echo "[agentsh startup] ERROR: $*" >&2
    exit 1
}

realpath_py() {
    python3 - "$1" <<'PY'
import os
import sys
print(os.path.realpath(sys.argv[1]))
PY
}

workspace_root() {
    local candidate single

    # Prefer an explicit workspace folder, but only if it actually exists inside
    # the container. Some tooling sets these to host paths that are not mounted
    # here, in which case they must be ignored.
    for candidate in "${DEVCONTAINER_WORKSPACE_FOLDER:-}" "${WORKSPACE_FOLDER:-}"; do
        if [ -n "$candidate" ] && [ -d "$candidate" ]; then
            realpath_py "$candidate"
            return 0
        fi
    done

    # The entrypoint usually runs from / before the workspace is the cwd.
    # Dev Containers mount the project under /workspaces/<name>; when exactly one
    # workspace is present, use it. Otherwise fall back to the cwd.
    single="$(find /workspaces -mindepth 1 -maxdepth 1 -type d 2>/dev/null)"
    if [ -n "$single" ] && [ "$(printf '%s\n' "$single" | wc -l)" -eq 1 ]; then
        realpath_py "$single"
    else
        realpath_py "$(pwd)"
    fi
}

resolve_overlay() {
    local root="$1"
    local requested="$2"
    local resolved

    [ -n "$requested" ] || { printf '\n'; return 0; }

    if [[ "$requested" = /* ]]; then
        resolved="$(realpath_py "$requested")"
    else
        resolved="$(realpath_py "${root}/${requested}")"
    fi

    # A non-existent overlay is the normal case (the default path usually does
    # not exist); fall back to the default policy rather than failing startup.
    [ -f "$resolved" ] || { printf '\n'; return 0; }

    # An overlay that DOES exist must be contained in the workspace root.
    case "$resolved" in
        "$root"|"$root"/*) printf '%s\n' "$resolved" ;;
        *)
            if [ "$root" = "/" ]; then
                printf '%s\n' "$resolved"
            else
                fail "policyOverlayPath resolves outside workspace root: $requested"
            fi
            ;;
    esac
}

assert_enforcement() {
    local detect_output
    detect_output="$(agentsh detect 2>&1)" || fail "agentsh detect failed during startup"
    if ! printf '%s\n' "$detect_output" | grep -Eiq 'landlock|full'; then
        fail "agentsh detect did not report Landlock-level or stronger enforcement"
    fi
}

start_server() {
    if [ -s "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" >/dev/null 2>&1; then
        log "agentsh server already running pid=$(cat "$PID_FILE")"
        return 0
    fi

    install -d -m 0755 "$(dirname "$PID_FILE")"
    agentsh server --config "$SERVER_RUNTIME_CONFIG_PATH" &
    echo "$!" > "$PID_FILE"
    log "agentsh server started pid=$(cat "$PID_FILE") config=${SERVER_RUNTIME_CONFIG_PATH}"
}

main() {
    local root overlay user_policy source

    [ -f "$SECURITY_FLOOR_PATH" ] || fail "Missing security floor: $SECURITY_FLOOR_PATH"
    [ -f "$DEFAULT_POLICY_PATH" ] || fail "Missing default policy: $DEFAULT_POLICY_PATH"
    [ -x "$MERGE_POLICY_PATH" ] || fail "Missing merge helper: $MERGE_POLICY_PATH"
    [ -f "$SERVER_RUNTIME_CONFIG_PATH" ] || fail "Missing server config: $SERVER_RUNTIME_CONFIG_PATH"

    root="$(workspace_root)"
    log "workspace root=${root} overlay-path=${POLICY_OVERLAY_PATH}"
    overlay="$(resolve_overlay "$root" "$POLICY_OVERLAY_PATH")"

    if [ -f "$overlay" ]; then
        user_policy="$overlay"
        source="overlay:${overlay}"
    else
        user_policy="$DEFAULT_POLICY_PATH"
        source="default"
    fi

    install -d -m 0755 "$(dirname "$RUNTIME_POLICY_PATH")"
    "$MERGE_POLICY_PATH" "$SECURITY_FLOOR_PATH" "$user_policy" > "$RUNTIME_POLICY_PATH" \
        || fail "Failed to merge security floor and selected policy"
    chmod 0644 "$RUNTIME_POLICY_PATH"

    log "policy source=${source}"
    log "policy floor=${SECURITY_FLOOR_PATH}"
    log "policy runtime=${RUNTIME_POLICY_PATH}"

    assert_enforcement
    start_server

    if [ "$#" -eq 0 ]; then
        set -- sleep infinity
    fi
    exec "$@"
}

main "$@"
