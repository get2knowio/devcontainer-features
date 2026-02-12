#!/bin/bash
set -e
source dev-container-features-test-lib

check "typescript installed" bash -c "command -v tsc"
check "prettier installed" bash -c "command -v prettier"
check "nodemon installed" bash -c "command -v nodemon"
check "bun not installed" bash -c "! command -v bun"

reportResults
