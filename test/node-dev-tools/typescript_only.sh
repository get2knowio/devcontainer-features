#!/bin/bash
set -e
source dev-container-features-test-lib

check "typescript installed" bash -c "command -v tsc"
check "ts-node installed" bash -c "command -v ts-node"
check "vite not installed" bash -c "! command -v vite"
check "bun not installed" bash -c "! command -v bun"

reportResults
