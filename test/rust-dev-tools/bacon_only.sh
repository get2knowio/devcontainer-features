#!/bin/bash
set -e
source dev-container-features-test-lib

check "bacon installed" bash -c "command -v bacon"
check "cargo-audit not installed" bash -c "! command -v cargo-audit"

reportResults
