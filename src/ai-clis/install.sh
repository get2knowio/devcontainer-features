#!/bin/bash
set -e

echo "Installing AI CLI tools..."

# In "selected" mode, only install CLIs explicitly set to true.
# In "all" mode (default), install everything unless explicitly set to false.
should_install() {
    local value="$1"
    if [ "${INSTALLMODE}" = "selected" ]; then
        [ "$value" = "true" ]
    else
        [ "$value" != "false" ]
    fi
}

# Claude Code - uses its own installer (npm install -g is deprecated)
if should_install "${CLAUDECODE}"; then
    echo "Installing Claude Code..."
    su - "$_REMOTE_USER" -c 'curl -fsSL https://claude.ai/install.sh | bash' || echo "Warning: Claude Code installation failed"
fi

# Gemini CLI
if should_install "${GEMINICLI}"; then
    echo "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
fi

# OpenAI Codex
if should_install "${CODEX}"; then
    echo "Installing OpenAI Codex..."
    npm install -g @openai/codex
fi

# GitHub Copilot CLI (requires Node 22+)
if should_install "${COPILOT}"; then
    echo "Installing GitHub Copilot CLI..."
    npm install -g @github/copilot
fi

# OpenCode AI
if should_install "${OPENCODE}"; then
    echo "Installing OpenCode AI..."
    npm install -g opencode-ai
fi

# CodeRabbit CLI
if should_install "${CODERABBIT}"; then
    echo "Installing CodeRabbit CLI..."
    curl -fsSL https://cli.coderabbit.ai/install.sh | sh
fi

# Beads - coding agent memory system
if should_install "${BEADS}"; then
    echo "Installing Beads..."
    npm install -g @beads/bd
fi

# Specify CLI - spec-driven development toolkit
if should_install "${SPECIFYCLI}"; then
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
