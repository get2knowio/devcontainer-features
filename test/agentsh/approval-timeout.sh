#!/bin/bash
set -e
source dev-container-features-test-lib

check "approvals enabled in authoritative config" bash -c "grep -A3 '^approvals:' /etc/agentsh/config.yaml | grep -q 'enabled: true'"
check "approval timeout reflects option" bash -c "grep -q 'timeout: \"30s\"' /etc/agentsh/config.yaml"

reportResults
