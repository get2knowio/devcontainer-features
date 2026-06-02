#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MERGE="${ROOT}/src/agentsh/scripts/merge-policy.py"
FLOOR="${ROOT}/src/agentsh/policies/security-floor.yaml"
DEFAULT="${ROOT}/src/agentsh/policies/example.yaml"
OVERLAY="${ROOT}/test/agentsh/fixtures/example-com-overlay.yaml"
MALFORMED="${ROOT}/test/agentsh/fixtures/malformed-overlay.yaml"
OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

"$MERGE" "$FLOOR" "$DEFAULT" > "$OUT"
grep -q "deny-agentsh-config-write" "$OUT"
grep -q "approve-unknown-network" "$OUT"

"$MERGE" "$FLOOR" "$OVERLAY" > "$OUT"
grep -q "deny-agentsh-config-write" "$OUT"
grep -q "allow-example-com" "$OUT"
if grep -q "approve-unknown-network" "$OUT"; then
    echo "overlay merge unexpectedly retained default policy" >&2
    exit 1
fi

if "$MERGE" "$FLOOR" "$MALFORMED" > "$OUT" 2>/dev/null; then
    echo "malformed overlay unexpectedly merged" >&2
    exit 1
fi

if "$MERGE" "${ROOT}/test/agentsh/fixtures/missing-floor.yaml" "$DEFAULT" > "$OUT" 2>/dev/null; then
    echo "missing floor unexpectedly merged" >&2
    exit 1
fi
