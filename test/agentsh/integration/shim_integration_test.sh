#!/usr/bin/env bash
#
# Validates real shell-shim mediation outside the Dev Container test harness.
#
# The harness bootstraps containers through /bin/sh and cannot start a container
# whose /bin/sh is the agentsh shim, so this builds the feature image with the
# production default (installShellShims=true) and inspects it through the
# unshimmed /bin/sh.real that agentsh creates.
#
# Requires Docker and a host kernel that provides Landlock (install.sh fails the
# build below Landlock-level enforcement). GitHub-hosted ubuntu runners qualify.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
BASE_IMAGE="${BASE_IMAGE:-mcr.microsoft.com/devcontainers/base:ubuntu}"
IMAGE="${IMAGE:-agentsh-shim-integration:test}"

cd "$REPO_ROOT"

echo "==> Building feature image with installShellShims=true (base: ${BASE_IMAGE})"
docker build \
  -f test/agentsh/integration/Dockerfile \
  --build-arg BASE_IMAGE="$BASE_IMAGE" \
  --build-arg INSTALLSHELLSHIMS=true \
  --build-arg SHIMFORCENONTTY=true \
  -t "$IMAGE" .

echo "==> Inspecting mediated shells through /bin/sh.real"
docker run --rm \
  --cap-add SYS_PTRACE \
  --security-opt seccomp=unconfined \
  "$IMAGE" /bin/sh.real -c '
    set -e
    echo "[shim] original shells preserved and runnable"
    test -x /bin/sh.real
    test -x /bin/bash.real
    /bin/sh.real -c "true"
    /bin/bash.real -c "true"

    echo "[shim] shim binary installed"
    test -x /usr/local/bin/agentsh-shell-shim

    echo "[shim] /bin/sh and /bin/bash are mediated"
    status="$(agentsh shim status --root / --bash --shim /usr/local/bin/agentsh-shell-shim)"
    printf "%s\n" "$status"
    printf "%s\n" "$status" | grep -q "sh: state=installed"
    printf "%s\n" "$status" | grep -q "bash: state=installed"
    test "$(printf "%s\n" "$status" | grep -c "shim_matches=true")" -ge 2

    echo "[shim] shimForceNonTty wrote /etc/agentsh/shim.conf with force=true"
    grep -q "force=true" /etc/agentsh/shim.conf

    echo "ALL SHIM INTEGRATION CHECKS PASSED"
  '
