#!/bin/bash
set -e

echo "Installing Node.js development tools..."

# If 'install' is set, only install the listed tool groups (comma-separated).
# Otherwise install everything unless individually disabled.
if [ -n "${INSTALL}" ]; then
    TYPESCRIPT="false"
    BUNDLERS="false"
    LINTERS="false"
    WATCHERS="false"
    BUN="false"

    IFS=',' read -ra SELECTED <<< "${INSTALL}"
    for item in "${SELECTED[@]}"; do
        item="$(echo "$item" | xargs)"
        case "$item" in
            typescript) TYPESCRIPT="true" ;;
            bundlers)   BUNDLERS="true" ;;
            linters)    LINTERS="true" ;;
            watchers)   WATCHERS="true" ;;
            bun)        BUN="true" ;;
            *) echo "Warning: unknown tool group '$item' in install list" ;;
        esac
    done
fi

# TypeScript toolchain
if [ "${TYPESCRIPT}" != "false" ]; then
    echo "Installing TypeScript toolchain..."
    npm install -g typescript ts-node tsx @types/node
fi

# Bundlers
if [ "${BUNDLERS}" != "false" ]; then
    echo "Installing bundlers..."
    npm install -g vite esbuild
fi

# Linters and formatters
if [ "${LINTERS}" != "false" ]; then
    echo "Installing linters and formatters..."
    npm install -g prettier eslint @biomejs/biome
fi

# File watchers
if [ "${WATCHERS}" != "false" ]; then
    echo "Installing file watchers..."
    npm install -g nodemon tsc-watch concurrently
fi

# Bun runtime
if [ "${BUN}" != "false" ]; then
    echo "Installing Bun..."
    su - "$_REMOTE_USER" -c 'curl -fsSL https://bun.sh/install | bash'
    # Create system-wide symlinks
    ln -sf "$_REMOTE_USER_HOME/.bun/bin/bun" /usr/local/bin/bun
    ln -sf "$_REMOTE_USER_HOME/.bun/bin/bunx" /usr/local/bin/bunx
fi

# --- Shell configuration ---
ZSHRC="$_REMOTE_USER_HOME/.zshrc"

cat >> "$ZSHRC" << 'ALIASES'
# TypeScript development aliases
alias tsc="npx tsc"
alias tsx="npx tsx"
alias tsw="npx tsc-watch"
alias dev="npm run dev"
alias build="npm run build"
alias test="npm test"
alias lint="npm run lint"
alias format="npm run format"
# Add npm completion if available
if command -v npm >/dev/null 2>&1; then eval "$(npm completion zsh)"; fi
ALIASES

if [ "${BUN}" != "false" ]; then
    echo 'export PATH="$HOME/.bun/bin:$PATH"' >> "$ZSHRC"
fi

echo "Node.js development tools installation complete."
