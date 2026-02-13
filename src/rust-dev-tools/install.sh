#!/bin/bash
set -e

echo "Installing Rust development tools..."

# Try to source cargo environment from common locations
for cargo_env in "/usr/local/cargo/env" "$_REMOTE_USER_HOME/.cargo/env" "$HOME/.cargo/env"; do
    if [ -f "$cargo_env" ]; then
        . "$cargo_env"
        break
    fi
done

# Ensure cargo is available
if ! command -v cargo >/dev/null 2>&1; then
    echo "Error: cargo not found. Install the Rust feature first."
    exit 1
fi

# If rustup is present, unconditionally ensure a default toolchain is installed.
# The rust:latest devcontainer image ships rustup shims without a default toolchain,
# causing "rustup could not choose a version of cargo" errors.
if command -v rustup >/dev/null 2>&1; then
    echo "Ensuring stable Rust toolchain is available..."
    rustup default stable 2>&1 || true
fi

# Capture the cargo bin directory for use in su - commands
# (su - resets PATH, losing Docker ENV vars like /usr/local/cargo/bin)
CARGO_BIN_DIR="$(dirname "$(command -v cargo)")"

# Step 1: All tools enabled by default
BACON="true"
CARGOEDIT="true"
CARGOAUDIT="true"

# Step 2: If install is set, whitelist mode
if [ -n "${INSTALL}" ]; then
    BACON="false"
    CARGOEDIT="false"
    CARGOAUDIT="false"

    IFS=',' read -ra SELECTED <<< "${INSTALL}"
    for item in "${SELECTED[@]}"; do
        item="$(echo "$item" | xargs)"
        case "$item" in
            bacon)      BACON="true" ;;
            cargoEdit)  CARGOEDIT="true" ;;
            cargoAudit) CARGOAUDIT="true" ;;
            *) echo "Warning: unknown tool '$item' in install list" ;;
        esac
    done
fi

# Step 3: If omit is set, blacklist filter
if [ -n "${OMIT}" ]; then
    IFS=',' read -ra EXCLUDED <<< "${OMIT}"
    for item in "${EXCLUDED[@]}"; do
        item="$(echo "$item" | xargs)"
        case "$item" in
            bacon)      BACON="false" ;;
            cargoEdit)  CARGOEDIT="false" ;;
            cargoAudit) CARGOAUDIT="false" ;;
            *) echo "Warning: unknown tool '$item' in omit list" ;;
        esac
    done
fi

# Helper: run cargo as the remote user with the correct environment.
# su - resets environment (losing Docker ENV vars), so we explicitly pass them.
RUSTUP_HOME="${RUSTUP_HOME:-/usr/local/rustup}"
CARGO_HOME="${CARGO_HOME:-/usr/local/cargo}"
cargo_as_user() {
    su - "$_REMOTE_USER" -c "export PATH=\"$CARGO_BIN_DIR:\$PATH\" RUSTUP_HOME=\"$RUSTUP_HOME\" CARGO_HOME=\"$CARGO_HOME\"; cargo $*"
}

# bacon (replaces archived cargo-watch)
if [ "${BACON}" = "true" ]; then
    echo "Installing bacon..."
    cargo_as_user install bacon || echo "Warning: bacon installation failed"
fi

# cargo-edit
if [ "${CARGOEDIT}" = "true" ]; then
    echo "Installing cargo-edit..."
    cargo_as_user install cargo-edit || echo "Warning: cargo-edit installation failed"
fi

# cargo-audit
if [ "${CARGOAUDIT}" = "true" ]; then
    echo "Installing cargo-audit..."
    cargo_as_user install cargo-audit || echo "Warning: cargo-audit installation failed"
fi

# --- Shell configuration ---
ZSHRC="$_REMOTE_USER_HOME/.zshrc"

cat >> "$ZSHRC" << 'ALIASES'
# Rust development aliases
alias cr="cargo run"
alias cb="cargo build"
alias ct="cargo test"
alias cc="cargo check"
alias cf="cargo fmt"
alias cl="cargo clippy"
alias cw="bacon"
alias cn="cargo new"
alias ca="cargo add"
alias cup="cargo update"
# Add rustup/cargo completion if available
if command -v rustup >/dev/null 2>&1; then
  mkdir -p ~/.zsh/completion
  rustup completions zsh > ~/.zsh/completion/_rustup 2>/dev/null || true
  rustup completions zsh cargo > ~/.zsh/completion/_cargo 2>/dev/null || true
  fpath=(~/.zsh/completion $fpath)
fi
ALIASES

echo "Rust development tools installation complete."
