#!/bin/bash
set -e
source dev-container-features-test-lib

check "claude code installed" bash -c "command -v claude"
check "gemini not installed" bash -c "! command -v gemini"
check "codex not installed" bash -c "! command -v codex"
check "beads not installed" bash -c "! command -v bd"

reportResults
