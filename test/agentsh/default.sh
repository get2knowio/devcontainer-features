#!/bin/bash
set -e
source dev-container-features-test-lib

check "Landlock-level enforcement detectable" bash -c "agentsh detect | grep -Eiq 'landlock|full'"
check "default policy contains SSH denial" bash -c "grep -q 'deny-ssh-private-keys' /etc/agentsh/policy.yaml"
check "default policy blocks env dump" bash -c "grep -q 'block-environment-dump' /etc/agentsh/policy.yaml"
check "default policy has approval fallback" bash -c "grep -q 'approve-unknown-network' /etc/agentsh/policy.yaml"
check "approvals enabled in authoritative config" bash -c "grep -A3 '^approvals:' /etc/agentsh/config.yaml | grep -q 'enabled: true'"

reportResults
