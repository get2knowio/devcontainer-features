#!/bin/bash
set -e

echo "Installing Node.js development tools..."

# TypeScript toolchain
if [ "${TYPESCRIPT}" = "true" ]; then
    echo "Installing TypeScript toolchain..."
    npm install -g typescript ts-node tsx @types/node
fi

# Bundlers
if [ "${BUNDLERS}" = "true" ]; then
    echo "Installing bundlers..."
    npm install -g vite esbuild
fi

# Linters and formatters
if [ "${LINTERS}" = "true" ]; then
    echo "Installing linters and formatters..."
    npm install -g prettier eslint @biomejs/biome
fi

# File watchers
if [ "${WATCHERS}" = "true" ]; then
    echo "Installing file watchers..."
    npm install -g nodemon tsc-watch concurrently
fi

# Bun runtime
if [ "${BUN}" = "true" ]; then
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

if [ "${BUN}" = "true" ]; then
    echo 'export PATH="$HOME/.bun/bin:$PATH"' >> "$ZSHRC"
fi

echo "Node.js development tools installation complete."
