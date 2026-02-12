#!/bin/bash
set -e
source dev-container-features-test-lib

check "uv installed" bash -c "command -v uv"
check "uv version" bash -c "uv --version"
check "poetry installed" bash -c "command -v poetry"
check "poetry version" bash -c "poetry --version"
check "ruff installed" bash -c "command -v ruff"
check "mypy installed" bash -c "command -v mypy"

reportResults
