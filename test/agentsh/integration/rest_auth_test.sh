#!/usr/bin/env bash
#
# Validates external REST API key authentication for real against agentsh.
#
# Builds the feature with externalRestApi=true (binds 0.0.0.0, enables api_key
# auth) and installShellShims=false (so a normal /bin/bash can drive the probe),
# starts the agentsh server from the authoritative /etc/agentsh/config.yaml, and
# asserts that an authenticated endpoint rejects missing/incorrect keys and
# accepts the configured key.
#
# This test isolates HTTP API-key authentication (the thing under test) from the
# sandbox transport: it disables sandbox.unix_sockets in the throwaway test
# container so the server's HTTP listener comes up on any kernel, including ones
# without seccomp user-notify. Auth behavior is independent of that setting.
#
# Requires Docker. Builds need a Landlock-capable host; GitHub-hosted ubuntu
# runners qualify.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
BASE_IMAGE="${BASE_IMAGE:-mcr.microsoft.com/devcontainers/base:ubuntu}"
IMAGE="${IMAGE:-agentsh-rest-auth:test}"
API_KEY="${API_KEY:-integration-rest-key}"

cd "$REPO_ROOT"

echo "==> Building feature image with externalRestApi=true, installShellShims=false (base: ${BASE_IMAGE})"
docker build \
  -f test/agentsh/integration/Dockerfile \
  --build-arg BASE_IMAGE="$BASE_IMAGE" \
  --build-arg INSTALLSHELLSHIMS=false \
  --build-arg EXTERNALRESTAPI=true \
  --build-arg RESTAPIKEY="$API_KEY" \
  -t "$IMAGE" .

echo "==> Probing authenticated REST endpoint"
docker run --rm \
  --cap-add SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --device /dev/fuse \
  -e API_KEY="$API_KEY" \
  "$IMAGE" /bin/bash -c '
    set -e
    # Isolate the HTTP auth check from the kernel sandbox transport.
    sed -i "/unix_sockets:/{n;s/enabled: true/enabled: false/}" /etc/agentsh/config.yaml
    agentsh server --config /etc/agentsh/config.yaml >/tmp/server.log 2>&1 &
    for _ in $(seq 1 30); do
      if curl -fsS -o /dev/null http://127.0.0.1:18080/health 2>/dev/null; then
        break
      fi
      sleep 0.5
    done
    echo "--- server log ---"; head -20 /tmp/server.log

    code_noauth="$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18080/api/v1/approvals)"
    code_auth="$(curl -s -o /dev/null -w "%{http_code}" -H "X-API-Key: ${API_KEY}" http://127.0.0.1:18080/api/v1/approvals)"
    code_bad="$(curl -s -o /dev/null -w "%{http_code}" -H "X-API-Key: wrong-key" http://127.0.0.1:18080/api/v1/approvals)"
    echo "no-key=${code_noauth} good-key=${code_auth} bad-key=${code_bad}"

    test "${code_noauth}" = "401"
    test "${code_auth}" = "200"
    test "${code_bad}" = "401"
    echo "ALL REST AUTH CHECKS PASSED"
  '
