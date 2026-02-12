#!/bin/bash
set -e
source dev-container-features-test-lib

check "claude code installed" bash -c "command -v claude"
check "gemini installed" bash -c "command -v gemini"
check "codex installed" bash -c "command -v codex"
check "copilot installed" bash -c "command -v github-copilot"
check "opencode installed" bash -c "command -v opencode"
check "coderabbit installed" bash -c "command -v coderabbit"
check "beads installed" bash -c "command -v bd"
check "specify installed" bash -c "command -v specify"

reportResults
