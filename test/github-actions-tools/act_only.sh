#!/bin/bash
set -e
source dev-container-features-test-lib

check "act installed" bash -c "command -v act"
check "actionlint not installed" bash -c "! command -v actionlint"

reportResults
