#!/bin/bash
set -e

echo "Installing Rust development tools..."

# Ensure cargo is available
if ! command -v cargo >/dev/null 2>&1; then
    echo "Error: cargo not found. Install the Rust feature first."
    exit 1
fi

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

# bacon (replaces archived cargo-watch)
if [ "${BACON}" = "true" ]; then
    echo "Installing bacon..."
    su - "$_REMOTE_USER" -c 'cargo install bacon' || echo "Warning: bacon installation failed"
fi

# cargo-edit
if [ "${CARGOEDIT}" = "true" ]; then
    echo "Installing cargo-edit..."
    su - "$_REMOTE_USER" -c 'cargo install cargo-edit' || echo "Warning: cargo-edit installation failed"
fi

# cargo-audit
if [ "${CARGOAUDIT}" = "true" ]; then
    echo "Installing cargo-audit..."
    su - "$_REMOTE_USER" -c 'cargo install cargo-audit' || echo "Warning: cargo-audit installation failed"
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
