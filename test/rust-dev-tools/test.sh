#!/bin/bash
set -e
source dev-container-features-test-lib

check "bacon installed" bash -c "command -v bacon"
check "cargo-edit installed" bash -c "cargo install --list | grep cargo-edit"
check "cargo-audit installed" bash -c "command -v cargo-audit"

reportResults
