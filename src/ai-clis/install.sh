#!/bin/bash
set -e

echo "Installing AI CLI tools..."

# Claude Code - uses its own installer (npm install -g is deprecated)
if [ "${CLAUDECODE}" = "true" ]; then
    echo "Installing Claude Code..."
    su - "$_REMOTE_USER" -c 'curl -fsSL https://claude.ai/install.sh | bash' || echo "Warning: Claude Code installation failed"
fi

# Gemini CLI
if [ "${GEMINICLI}" = "true" ]; then
    echo "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
fi

# OpenAI Codex
if [ "${CODEX}" = "true" ]; then
    echo "Installing OpenAI Codex..."
    npm install -g @openai/codex
fi

# GitHub Copilot CLI (requires Node 22+)
if [ "${COPILOT}" = "true" ]; then
    echo "Installing GitHub Copilot CLI..."
    npm install -g @github/copilot
fi

# OpenCode AI
if [ "${OPENCODE}" = "true" ]; then
    echo "Installing OpenCode AI..."
    npm install -g opencode-ai
fi

# CodeRabbit CLI
if [ "${CODERABBIT}" = "true" ]; then
    echo "Installing CodeRabbit CLI..."
    curl -fsSL https://cli.coderabbit.ai/install.sh | sh
fi

# Beads - coding agent memory system
if [ "${BEADS}" = "true" ]; then
    echo "Installing Beads..."
    npm install -g @beads/bd
fi

# Specify CLI - spec-driven development toolkit
if [ "${SPECIFYCLI}" = "true" ]; then
    echo "Installing Specify CLI (spec-kit) via uv..."
    # Ensure uv is available
    if command -v uv >/dev/null 2>&1; then
        UV_BIN="$(command -v uv)"
    else
        echo "uv not found; installing via Astral script..."
        su - "$_REMOTE_USER" -c 'curl -Ls https://astral.sh/uv/install.sh | sh'
        UV_BIN="$_REMOTE_USER_HOME/.local/bin/uv"
    fi
    # Ensure ~/.local/bin on PATH
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$_REMOTE_USER_HOME/.zshrc"
    su - "$_REMOTE_USER" -c "\"$UV_BIN\" tool install specify-cli --from git+https://github.com/github/spec-kit.git" || echo "Warning: Specify CLI installation failed"
fi

echo "AI CLI tools installation complete."
