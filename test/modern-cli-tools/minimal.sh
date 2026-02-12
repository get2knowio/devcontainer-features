#!/bin/bash
set -e
source dev-container-features-test-lib

check "bat installed" bash -c "command -v bat"
check "ripgrep installed" bash -c "command -v rg"
check "eza not installed" bash -c "! command -v eza"
check "lazygit not installed" bash -c "! command -v lazygit"

reportResults
