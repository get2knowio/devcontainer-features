#!/bin/bash
set -e
source dev-container-features-test-lib

check "poetry installed" bash -c "command -v poetry"
check "poetry version" bash -c "poetry --version"

reportResults
