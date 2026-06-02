#!/bin/bash
set -euo pipefail

AGENTSH_VERSION="${VERSION:-0.20.2}"
APPROVAL_TIMEOUT_SECONDS="${APPROVALTIMEOUTSECONDS:-300}"
SHIM_FORCE_NON_TTY="${SHIMFORCENONTTY:-true}"
INSTALL_SHELL_SHIMS="${INSTALLSHELLSHIMS:-true}"
INSTALL_DEV_DEPENDENCIES="${INSTALLDEVDEPENDENCIES:-true}"
POLICY_OVERLAY_PATH="${POLICYOVERLAYPATH:-.devcontainer/agentsh-policy.yaml}"
EXTERNAL_REST_API="${EXTERNALRESTAPI:-false}"
REST_PORT="${RESTPORT:-18080}"
REST_API_KEY="${RESTAPIKEY:-}"

INSTALL_ROOT="/usr/local/share/agentsh"
ORIGINAL_SHELL_DIR="${INSTALL_ROOT}/original"
DEFAULT_POLICY_PATH="/etc/agentsh/policy.yaml"
CONFIG_PATH="/etc/agentsh/config.yaml"
SECURITY_FLOOR_PATH="${INSTALL_ROOT}/security-floor.yaml"
START_SERVER_PATH="${INSTALL_ROOT}/start-server.sh"
MERGE_POLICY_PATH="${INSTALL_ROOT}/merge-policy.py"
SHIM_PATH="/usr/local/bin/agentsh-shell-shim"
UNIXWRAP_PATH="/usr/local/bin/agentsh-unixwrap"
API_KEYS_PATH="/etc/agentsh/api_keys.yaml"
FEATURE_ENV_PATH="/etc/agentsh/feature.env"

log() {
    echo "[agentsh feature] $*"
}

fail() {
    echo "[agentsh feature] ERROR: $*" >&2
    exit 1
}

as_bool() {
    case "$1" in
        [Tt][Rr][Uu][Ee]|1|[Yy][Ee][Ss]|[Yy]) return 0 ;;
        [Ff][Aa][Ll][Ss][Ee]|0|[Nn][Oo]|[Nn]|"") return 1 ;;
        *) fail "Invalid boolean value: $1" ;;
    esac
}

yaml_single_quote() {
    printf "'%s'" "$(printf '%s' "$1" | sed "s/'/''/g")"
}

validate_positive_integer() {
    local name="$1"
    local value="$2"

    case "$value" in
        ''|*[!0-9]*) fail "${name} must be a positive integer" ;;
    esac
    if [ "$value" -le 0 ]; then
        fail "${name} must be a positive integer"
    fi
}

detect_arch() {
    local arch
    if command -v dpkg >/dev/null 2>&1; then
        arch="$(dpkg --print-architecture)"
    else
        arch="$(uname -m)"
    fi

    case "$arch" in
        amd64|x86_64) echo "amd64" ;;
        arm64|aarch64) echo "arm64" ;;
        *) fail "Unsupported CPU architecture: $arch" ;;
    esac
}

detect_libc() {
    if ldd --version 2>&1 | grep -qi musl || ls /lib/ld-musl-*.so.1 >/dev/null 2>&1; then
        echo "musl"
    else
        echo "glibc"
    fi
}

install_dependencies() {
    as_bool "$INSTALL_DEV_DEPENDENCIES" || return 0

    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get install -y --no-install-recommends ca-certificates curl jq tar bash python3 python3-yaml
        apt-get clean
        rm -rf /var/lib/apt/lists/*
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache ca-certificates curl jq tar bash python3 py3-yaml
    else
        fail "Unsupported base image: expected apt-get or apk"
    fi
}

download_file() {
    local url="$1"
    local output="$2"
    log "Downloading $url"
    curl -fsSL "$url" -o "$output"
}

verify_checksum() {
    local version="$1"
    local asset_name="$2"
    local asset_path="$3"
    local tmp_dir="$4"
    local manifest manifest_url checksum

    for manifest in checksums.txt SHA256SUMS sha256sums.txt; do
        manifest_url="https://github.com/canyonroad/agentsh/releases/download/v${version}/${manifest}"
        if curl -fsSL "$manifest_url" -o "${tmp_dir}/${manifest}" 2>/dev/null; then
            checksum="$(awk -v f="$asset_name" '$0 ~ f { print $1; exit }' "${tmp_dir}/${manifest}")"
            if [ -n "$checksum" ]; then
                printf '%s  %s\n' "$checksum" "$asset_path" | sha256sum -c -
                return 0
            fi
        fi
    done

    fail "No checksum entry found for ${asset_name} in release v${version}"
}

install_agentsh_binary() {
    local arch="$1"
    local libc="$2"
    local tmp_dir asset_name asset_url asset_path

    tmp_dir="$(mktemp -d)"

    if [ "$libc" = "musl" ]; then
        asset_name="agentsh_v${AGENTSH_VERSION}_linux_${arch}_musl.tar.gz"
    else
        asset_name="agentsh_${AGENTSH_VERSION}_linux_${arch}.deb"
    fi
    asset_url="https://github.com/canyonroad/agentsh/releases/download/v${AGENTSH_VERSION}/${asset_name}"
    asset_path="${tmp_dir}/${asset_name}"

    download_file "$asset_url" "$asset_path"
    verify_checksum "$AGENTSH_VERSION" "$asset_name" "$asset_path" "$tmp_dir"

    if [ "$libc" = "musl" ]; then
        # The musl tarball ships the helper binaries alongside agentsh; install
        # the shim and unix-socket wrapper too (the .deb places these on PATH).
        tar -xzf "$asset_path" -C "$tmp_dir" agentsh agentsh-shell-shim agentsh-unixwrap
        install -m 0755 "${tmp_dir}/agentsh" /usr/local/bin/agentsh
        install -m 0755 "${tmp_dir}/agentsh-shell-shim" "$SHIM_PATH"
        install -m 0755 "${tmp_dir}/agentsh-unixwrap" "$UNIXWRAP_PATH"
    else
        dpkg -i "$asset_path" || apt-get install -f -y
        if [ ! -x /usr/local/bin/agentsh ]; then
            local installed_bin
            installed_bin="$(command -v agentsh || true)"
            [ -n "$installed_bin" ] || fail "agentsh package installed but no agentsh binary was found on PATH"
            install -m 0755 "$installed_bin" /usr/local/bin/agentsh
        else
            chmod 0755 /usr/local/bin/agentsh
        fi
    fi

    if command -v agentsh-shell-shim >/dev/null 2>&1 && [ "$(command -v agentsh-shell-shim)" != "$SHIM_PATH" ]; then
        install -m 0755 "$(command -v agentsh-shell-shim)" "$SHIM_PATH"
    fi

    rm -rf "$tmp_dir"
}

install_assets() {
    install -d -m 0755 /etc/agentsh "$INSTALL_ROOT" "$ORIGINAL_SHELL_DIR"
    install -m 0444 "$(dirname "$0")/policies/security-floor.yaml" "$SECURITY_FLOOR_PATH"
    install -m 0644 "$(dirname "$0")/policies/example.yaml" "$DEFAULT_POLICY_PATH"
    install -m 0755 "$(dirname "$0")/scripts/start-server.sh" "$START_SERVER_PATH"
    install -m 0755 "$(dirname "$0")/scripts/merge-policy.py" "$MERGE_POLICY_PATH"
}

write_api_keys_file() {
    if [ -z "$REST_API_KEY" ]; then
        rm -f "$API_KEYS_PATH"
        return 0
    fi

    # agentsh expects a root-level YAML list of {name, key} entries
    # (auth.keyFileEntry), not a mapping under an api_keys key.
    umask 077
    cat > "$API_KEYS_PATH" <<EOF
- name: "external-notifier"
  key: $(yaml_single_quote "$REST_API_KEY")
EOF
    chmod 0600 "$API_KEYS_PATH"
}

write_profile_env() {
    cat > /etc/profile.d/agentsh.sh <<EOF
export AGENTSH_SERVER="http://127.0.0.1:${REST_PORT}"
EOF
    chmod 0644 /etc/profile.d/agentsh.sh
}

write_feature_env() {
    # Persist option values the entrypoint needs at container start, since the
    # feature option environment variables are only present during install.
    cat > "$FEATURE_ENV_PATH" <<EOF
export POLICYOVERLAYPATH='${POLICY_OVERLAY_PATH}'
EOF
    chmod 0644 "$FEATURE_ENV_PATH"
}

write_config() {
    local approval_timeout="${APPROVAL_TIMEOUT_SECONDS}s"
    local rest_bind_address="127.0.0.1"
    local auth_type="none"
    local api_keys_yaml=""

    if as_bool "$EXTERNAL_REST_API"; then
        rest_bind_address="0.0.0.0"
    fi
    if [ -n "$REST_API_KEY" ]; then
        auth_type="api_key"
        api_keys_yaml="  api_key:
    keys_file: \"${API_KEYS_PATH}\"
    header_name: \"X-API-Key\""
    fi

    # /etc/agentsh/config.yaml is the authoritative config agentsh reads.
    cat > "$CONFIG_PATH" <<EOF
server:
  http:
    addr: "${rest_bind_address}:${REST_PORT}"
    read_timeout: "30s"
    write_timeout: "60s"
    max_request_size: "10MB"
  grpc:
    enabled: true
    addr: "127.0.0.1:9090"
  unix_socket:
    enabled: false
    path: "/var/run/agentsh/agentsh.sock"
    permissions: "0660"
auth:
  type: "${auth_type}"
${api_keys_yaml}
logging:
  level: "info"
  format: "json"
  output: "stderr"
sessions:
  base_dir: "/var/lib/agentsh/sessions"
  max_sessions: 100
  default_timeout: "1h"
  default_idle_timeout: "15m"
  cleanup_interval: "5m"
audit:
  enabled: true
  storage:
    sqlite_path: "/var/lib/agentsh/events.db"
sandbox:
  enabled: true
  allow_degraded: false
  limits:
    max_memory_mb: 4096
    max_cpu_percent: 100
    max_processes: 256
  fuse:
    enabled: true
    audit:
      enabled: true
      mode: "soft_delete"
      trash_path: ".agentsh_trash"
      ttl: "24h"
      quota: "1GB"
  network:
    enabled: true
    intercept_mode: "all"
    proxy_listen_addr: "127.0.0.1:0"
  cgroups:
    enabled: false
  seccomp:
    shellc:
      opaque: "allow"
  unix_sockets:
    enabled: true
proxy:
  mode: "embedded"
  port: 0
  providers:
    anthropic: "https://api.anthropic.com"
    openai: "https://api.openai.com"
dlp:
  mode: "redact"
  patterns:
    email: true
    phone: true
    credit_card: true
    ssn: true
    api_keys: true
policies:
  dir: "/run/agentsh"
  default: "policy"
  symlink_escape: "evaluate"
security:
  minimum_mode: "landlock"
  warn_degraded: true
approvals:
  enabled: true
  mode: "async"
  timeout: "${approval_timeout}"
metrics:
  enabled: true
  path: "/metrics"
health:
  path: "/health"
  readiness_path: "/ready"
development:
  disable_auth: false
  verbose_errors: false
EOF
    chmod 0644 "$CONFIG_PATH"
}

seed_runtime_policy() {
    install -d -m 0755 /run/agentsh
    "$MERGE_POLICY_PATH" "$SECURITY_FLOOR_PATH" "$DEFAULT_POLICY_PATH" > /run/agentsh/policy.yaml
    chmod 0644 /run/agentsh/policy.yaml
}

install_shell_shims() {
    local shim_args

    [ -x "$SHIM_PATH" ] || fail "agentsh shell shim binary was not installed at $SHIM_PATH"

    shim_args=(shim install-shell --root / --shim "$SHIM_PATH" --bash --i-understand-this-modifies-the-host)
    if as_bool "$SHIM_FORCE_NON_TTY"; then
        shim_args+=(--force)
    fi

    agentsh "${shim_args[@]}"
}

verify_agentsh() {
    local version_output detect_output

    version_output="$(agentsh --version 2>&1)" || fail "agentsh --version failed"
    detect_output="$(agentsh detect 2>&1)" || fail "agentsh detect failed"

    # The asset is pinned by download URL and checksum-verified above, so the
    # installed artifact is already guaranteed to be the requested release. The
    # version-string check is redundant defense-in-depth and is only a warning:
    # upstream musl builds report "agentsh dev" without embedding the version.
    if ! printf '%s\n' "$version_output" | grep -Fq "$AGENTSH_VERSION"; then
        log "WARNING: agentsh --version (${version_output}) does not embed the expected ${AGENTSH_VERSION}; relying on the pinned, checksum-verified download"
    fi

    if ! printf '%s\n' "$detect_output" | grep -Eiq 'landlock|full'; then
        fail "agentsh detect did not report Landlock-level or stronger enforcement"
    fi

    log "Installed ${version_output}"
    log "Enforcement detection includes Landlock-level support"
}

main() {
    local arch libc

    validate_positive_integer "approvalTimeoutSeconds" "$APPROVAL_TIMEOUT_SECONDS"
    validate_positive_integer "restPort" "$REST_PORT"
    if [ "$APPROVAL_TIMEOUT_SECONDS" -le 0 ]; then
        fail "approvalTimeoutSeconds must be positive"
    fi
    if as_bool "$EXTERNAL_REST_API" && [ -z "$REST_API_KEY" ]; then
        fail "externalRestApi requires restApiKey"
    fi

    arch="$(detect_arch)"
    libc="$(detect_libc)"
    log "Installing agentsh ${AGENTSH_VERSION} for ${arch}/${libc}"

    install_dependencies
    install_agentsh_binary "$arch" "$libc"
    install_assets
    write_api_keys_file
    write_profile_env
    write_feature_env
    write_config
    seed_runtime_policy
    if as_bool "$INSTALL_SHELL_SHIMS"; then
        install_shell_shims
    else
        log "Shell shims disabled (installShellShims=false); /bin/sh and /bin/bash are left unmodified"
    fi
    verify_agentsh

    if ! as_bool "$INSTALL_SHELL_SHIMS"; then
        log "Non-TTY shell shim forcing is not applicable while shell shims are disabled"
    elif as_bool "$SHIM_FORCE_NON_TTY"; then
        log "Non-TTY shell shim forcing is enabled"
    else
        log "Non-TTY shell shim forcing is disabled"
    fi

    log "Default policy: ${DEFAULT_POLICY_PATH}"
    log "Security floor: ${SECURITY_FLOOR_PATH}"
    log "Overlay path: ${POLICY_OVERLAY_PATH}"
    log "Approvals: enabled (async; resolved via the agentsh REST API)"
    if as_bool "$EXTERNAL_REST_API"; then
        log "External REST API: enabled on 0.0.0.0:${REST_PORT}"
    else
        log "External REST API: disabled; listening on 127.0.0.1:${REST_PORT}"
    fi
}

main "$@"
