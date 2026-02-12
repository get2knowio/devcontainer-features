#!/bin/bash
set -e
source dev-container-features-test-lib

check "act installed" bash -c "command -v act"
check "act version" bash -c "act --version"
check "actionlint installed" bash -c "command -v actionlint"
check "actionlint version" bash -c "actionlint --version"

reportResults
