#!/bin/bash
set -e
source dev-container-features-test-lib

check "external REST API binds all interfaces" bash -c "grep -q 'addr: \"0.0.0.0:18080\"' /etc/agentsh/config.yaml"
check "API key auth enabled" bash -c "grep -q 'type: \"api_key\"' /etc/agentsh/config.yaml"
check "API key file installed" bash -c "sudo test -f /etc/agentsh/api_keys.yaml"
# api_keys.yaml is mode 0600 (secret), so read it via sudo in the test harness,
# which runs assertions as a non-root user. agentsh expects a root-level YAML
# list of {name, key} entries, not a map.
check "API key file uses root list shape" bash -c "sudo grep -qE '^- name: \"external-notifier\"' /etc/agentsh/api_keys.yaml"
check "API key file is not a map" bash -c "! sudo grep -q '^api_keys:' /etc/agentsh/api_keys.yaml"
check "API key file has key entry" bash -c "sudo grep -qE '^  key:' /etc/agentsh/api_keys.yaml"

reportResults
