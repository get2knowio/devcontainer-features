#!/bin/bash
set -e
source dev-container-features-test-lib

# The harness mounts test/agentsh/ as the workspace root, so fixtures/ is at the
# workspace root. Resolve the fixture there, falling back to the in-repo path.
MALFORMED="${DEVCONTAINER_WORKSPACE_FOLDER:-/workspaces}/fixtures/malformed-overlay.yaml"
[ -f "$MALFORMED" ] || MALFORMED="$(find /workspaces -name malformed-overlay.yaml 2>/dev/null | head -1)"

check "malformed overlay file present" bash -c "test -f '${MALFORMED}'"
check "malformed overlay fails merge" bash -c "! /usr/local/share/agentsh/merge-policy.py /usr/local/share/agentsh/security-floor.yaml '${MALFORMED}' >/tmp/agentsh-bad-policy.yaml"

reportResults
