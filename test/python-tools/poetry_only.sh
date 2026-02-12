#!/bin/bash
set -e
source dev-container-features-test-lib

check "poetry installed" bash -c "command -v poetry"
check "poetry version" bash -c "poetry --version"
check "poetry in-project venvs" bash -c "poetry config virtualenvs.in-project | grep -i true"

reportResults
