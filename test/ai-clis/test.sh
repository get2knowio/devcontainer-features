#!/bin/bash
set -e
source dev-container-features-test-lib

check "claude code installed" bash -c "command -v claude"
check "claude-agent-acp installed" bash -c "command -v claude-agent-acp"
check "gemini installed" bash -c "command -v gemini"
check "codex installed" bash -c "command -v codex"
check "copilot installed" bash -c "command -v copilot"
check "opencode installed" bash -c "command -v opencode"
check "coderabbit installed" bash -c "command -v coderabbit"
check "dolt installed" bash -c "command -v dolt"
check "beads installed" bash -c "command -v bd"
check "specify installed" bash -c "command -v specify"

reportResults
