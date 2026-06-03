#!/usr/bin/env bash
#
# Validates policy overlay selection and security-floor self-protection in a
# controlled container, deterministically (the Dev Container test harness's
# entrypoint orchestration does not reliably expose the workspace mount to the
# feature entrypoint, so overlay-at-startup is validated here instead).
#
# Builds the feature with shims disabled, mounts the test directory as the
# workspace, points policyOverlayPath at an overlay fixture, runs the real
# entrypoint, and asserts the merged runtime policy.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
BASE_IMAGE="${BASE_IMAGE:-mcr.microsoft.com/devcontainers/base:ubuntu}"
IMAGE="${IMAGE:-agentsh-overlay-integration:test}"

cd "$REPO_ROOT"

echo "==> Building feature image (installShellShims=false)"
docker build \
  -f test/agentsh/integration/Dockerfile \
  --build-arg BASE_IMAGE="$BASE_IMAGE" \
  --build-arg INSTALLSHELLSHIMS=false \
  -t "$IMAGE" .

echo "==> Selecting an overlay and asserting the merged runtime policy"
docker run --rm \
  --cap-add SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --mount type=bind,source="${REPO_ROOT}/test/agentsh",target=/workspaces/ws,readonly \
  "$IMAGE" /bin/bash -c '
    set -e
    # Point the entrypoint at the overlay fixture (relative to the workspace).
    echo "export POLICYOVERLAYPATH=fixtures/example-com-overlay.yaml" > /etc/agentsh/feature.env
    /usr/local/share/agentsh/start-server.sh true >/tmp/start.log 2>&1 || true
    echo "--- startup log ---"; grep -E "workspace root=|policy source=" /tmp/start.log || true

    echo "[overlay] overlay was selected"
    grep -q "policy source=overlay" /tmp/start.log

    echo "[overlay] overlay rule present in runtime policy"
    grep -q "allow-example-com" /run/agentsh/policy.yaml

    echo "[overlay] default policy was replaced (no approve-unknown-network)"
    ! grep -q "approve-unknown-network" /run/agentsh/policy.yaml

    echo "[self-protection] security floor prepended even under a custom overlay"
    grep -q "deny-agentsh-config-write" /run/agentsh/policy.yaml
    grep -q "/etc/agentsh/\*\*" /run/agentsh/policy.yaml
    awk "/deny-agentsh-config-write/{f=1} /allow-example-com/{exit !f}" /run/agentsh/policy.yaml

    echo "ALL OVERLAY INTEGRATION CHECKS PASSED"
  '
