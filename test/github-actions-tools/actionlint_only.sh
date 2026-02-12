#!/bin/bash
set -e
source dev-container-features-test-lib

check "actionlint installed" bash -c "command -v actionlint"
check "act not installed" bash -c "! command -v act"

reportResults
