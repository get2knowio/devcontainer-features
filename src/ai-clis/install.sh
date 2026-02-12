#!/bin/bash
set -e

echo "Installing AI CLI tools..."

# If 'install' is set, only install the listed CLIs (comma-separated).
# Otherwise install everything unless individually disabled.
if [ -n "${INSTALL}" ]; then
    CLAUDECODE="false"
    GEMINICLI="false"
    CODEX="false"
    COPILOT="false"
    OPENCODE="false"
    CODERABBIT="false"
    BEADS="false"
    SPECIFYCLI="false"

    IFS=',' read -ra SELECTED <<< "${INSTALL}"
    for item in "${SELECTED[@]}"; do
        item="$(echo "$item" | xargs)"
        case "$item" in
            claudeCode)  CLAUDECODE="true" ;;
            geminiCli)   GEMINICLI="true" ;;
            codex)       CODEX="true" ;;
            copilot)     COPILOT="true" ;;
            openCode)    OPENCODE="true" ;;
            codeRabbit)  CODERABBIT="true" ;;
            beads)       BEADS="true" ;;
            specifyCli)  SPECIFYCLI="true" ;;
            *) echo "Warning: unknown CLI '$item' in install list" ;;
        esac
    done
fi

# Claude Code - uses its own installer (npm install -g is deprecated)
if [ "${CLAUDECODE}" != "false" ]; then
    echo "Installing Claude Code..."
    su - "$_REMOTE_USER" -c 'curl -fsSL https://claude.ai/install.sh | bash' || echo "Warning: Claude Code installation failed"
fi

# Gemini CLI
if [ "${GEMINICLI}" != "false" ]; then
    echo "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
fi

# OpenAI Codex
if [ "${CODEX}" != "false" ]; then
    echo "Installing OpenAI Codex..."
    npm install -g @openai/codex
fi

# GitHub Copilot CLI (requires Node 22+)
if [ "${COPILOT}" != "false" ]; then
    echo "Installing GitHub Copilot CLI..."
    npm install -g @github/copilot
fi

# OpenCode AI
if [ "${OPENCODE}" != "false" ]; then
    echo "Installing OpenCode AI..."
    npm install -g opencode-ai
fi

# CodeRabbit CLI
if [ "${CODERABBIT}" != "false" ]; then
    echo "Installing CodeRabbit CLI..."
    curl -fsSL https://cli.coderabbit.ai/install.sh | sh
fi

# Beads - coding agent memory system
if [ "${BEADS}" != "false" ]; then
    echo "Installing Beads..."
    npm install -g @beads/bd
fi

# Specify CLI - spec-driven development toolkit
if [ "${SPECIFYCLI}" != "false" ]; then
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
