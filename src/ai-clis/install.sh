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

echo "AI CLI tools installation complete."
