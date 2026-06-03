#!/bin/bash
set -e
source dev-container-features-test-lib

check "missing floor fails merge" bash -c "! /usr/local/share/agentsh/merge-policy.py /tmp/agentsh-missing-floor.yaml /etc/agentsh/policy.yaml >/tmp/agentsh-bad-policy.yaml"

reportResults
