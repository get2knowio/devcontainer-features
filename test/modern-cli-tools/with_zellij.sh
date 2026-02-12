#!/bin/bash
set -e
source dev-container-features-test-lib

check "zellij installed" bash -c "command -v zellij"
check "bat installed" bash -c "command -v bat"

reportResults
