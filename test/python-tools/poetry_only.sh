#!/bin/bash
set -e
source dev-container-features-test-lib

check "poetry installed" bash -c "command -v poetry"
check "poetry version" bash -c "poetry --version"
check "uv not installed" bash -c "! command -v uv"
check "ruff not installed" bash -c "! command -v ruff"

reportResults
