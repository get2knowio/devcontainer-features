#!/bin/bash
set -e
source dev-container-features-test-lib

check "gemini installed" bash -c "command -v gemini"
check "codex installed" bash -c "command -v codex"
check "copilot installed" bash -c "command -v copilot"
check "opencode installed" bash -c "command -v opencode"
check "claude not installed" bash -c "! command -v claude"
check "coderabbit not installed" bash -c "! command -v coderabbit"
check "qmd not installed" bash -c "! command -v qmd"
check "claude-agent-acp not installed" bash -c "! command -v claude-agent-acp"

reportResults
