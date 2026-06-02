# Contract: Agentsh Dev Container Feature

## Canonical Feature URI

Consumers reference the feature as:

```jsonc
"ghcr.io/get2knowio/devcontainer-features/agentsh:0.1.0": {}
```

## Feature Metadata

`src/agentsh/devcontainer-feature.json` must expose:

| Field | Contract |
|-------|----------|
| `id` | `agentsh` |
| `version` | `0.1.0` for first release |
| `name` | `agentsh` |
| `documentationURL` | `https://github.com/get2knowio/devcontainer-features/tree/main/src/agentsh` |
| `description` | Describes agentsh execution-layer security, shell shims, policy, and REST API approvals |
| `installsAfter` | Includes `ghcr.io/devcontainers/features/common-utils` |
| `entrypoint` | `/usr/local/share/agentsh/start-server.sh` |

Runtime declarations:

| Field | Contract |
|-------|----------|
| `containerEnv.AGENTSH_SERVER` | `http://127.0.0.1:18080` |
| `containerEnv.AGENTSH_SHIM_FORCE` | `1` when non-TTY forcing is enabled |
| `capAdd` | Includes `SYS_PTRACE` |
| `securityOpt` | Includes `seccomp=unconfined` |
| `mounts` | Binds `/dev/fuse` to `/dev/fuse` |

## Options

| Option | Type | Default | Contract |
|--------|------|---------|----------|
| `version` | string | `0.20.2` | Pinned agentsh stable release without `v`; re-check immediately before release |
| `approvalTimeoutSeconds` | string | `"300"` | Approval wait before fail-secure deny (config.yaml `approvals.timeout`) |
| `shimForceNonTty` | boolean | `true` | Forces shims for non-interactive agent subprocesses |
| `installShellShims` | boolean | `true` | Replaces `/bin/sh` and `/bin/bash` with the agentsh shim. `true` is the secure default; `false` is a validation/advanced option that still installs agentsh, policy assets, config, and the shim binary but leaves the system shells unmodified |
| `installDevDependencies` | boolean | `true` | Installs required OS packages when missing |
| `policyOverlayPath` | string | `.devcontainer/agentsh-policy.yaml` | Workspace-relative user policy replacement path |
| `externalRestApi` | boolean | `false` | Binds REST API on all container interfaces for sidecar notifier polling |
| `restPort` | string | `"18080"` | REST API port |
| `restApiKey` | string | `""` | API key for REST clients; required when `externalRestApi` is true |

## Install-Time Contract

`src/agentsh/install.sh` is a POSIX `/bin/sh` bootstrap that ensures Bash is
present (Alpine ships without it) and then execs `src/agentsh/install-main.sh`.
`src/agentsh/install-main.sh` must:

1. Use Bash strict mode.
2. Detect CPU architecture and libc family. For the musl tarball, install
   `agentsh`, `agentsh-shell-shim`, and `agentsh-unixwrap` (the `.deb` provides
   these on PATH automatically). Treat a `--version` string that omits the
   pinned version as a warning, not a failure, because the integrity guarantee
   is the pinned, checksum-verified download (musl builds report `agentsh dev`).
3. Install prerequisites for Debian/Ubuntu and Alpine when enabled.
4. Download the pinned upstream agentsh asset appropriate to architecture/libc.
5. Verify release checksum or trusted release digest and fail when unavailable.
6. Install `/usr/local/bin/agentsh` mode `0755`.
7. Install shell shims for both `/bin/bash` and `/bin/sh` when `installShellShims` is `true` (the default). When `false`, still install the `/usr/local/bin/agentsh-shell-shim` binary and all other assets, but leave `/bin/sh` and `/bin/bash` unmodified.
8. Copy policy, floor, entrypoint, and merge script with root-owned read-only/executable modes.
9. Render `/etc/agentsh/config.yaml` (the single authoritative config agentsh reads) with private REST binding by default, external sidecar binding only when explicitly enabled, API-key auth for external REST access, `policies.dir`/`policies.default` pointing at the merged runtime policy, `approvals.enabled: true` with `approvals.timeout` from `approvalTimeoutSeconds`, and `security.minimum_mode: landlock`. No `server.yaml` is written.
9b. When external REST is enabled, write `/etc/agentsh/api_keys.yaml` (mode `0600`) as a root-level YAML list of `{name, key}` entries (the `auth.keyFileEntry` shape agentsh requires), not a map.
9c. Persist runtime-relevant option values (currently `policyOverlayPath`) to `/etc/agentsh/feature.env`, because feature option environment variables are not available to the entrypoint at container start.
10. Verify `agentsh --version` and `agentsh detect`.
11. Fail if detected enforcement cannot satisfy Landlock-level or stronger protection.
12. Print installed version, enforcement mode, policy source behavior, and approval/REST settings.

## Runtime Contract

`src/agentsh/scripts/start-server.sh` must:

1. Source `/etc/agentsh/feature.env`, resolve the workspace root (preferring `DEVCONTAINER_WORKSPACE_FOLDER`/`WORKSPACE_FOLDER`, then a single `/workspaces/*` directory, then the cwd), and resolve `policyOverlayPath`. A non-existent overlay must fall back to the default policy without failing; an overlay that exists but resolves outside the workspace root must fail loud.
2. Select overlay when present, otherwise default policy.
3. Validate and merge security floor ahead of selected user policy.
4. Write `/run/agentsh/policy.yaml`.
5. Log policy source and floor path.
6. Start `agentsh server --config /etc/agentsh/config.yaml` (the authoritative config) if not already running.
7. Fail startup on invalid floor, invalid selected policy, merge failure, or enforcement below minimum.
8. `exec "$@"` after server startup.

## Documentation Contract

Docs must include:

- Canonical feature URI and first release version.
- Option table matching metadata.
- How policy `approve` decisions are served over the REST API and resolved by a notifier sidecar; behavior when no approver is attached (fail-secure deny after timeout).
- Security floor explanation and why it cannot be disabled.
- Overlay customization recipes.
- Minimum enforcement behavior and troubleshooting.
- Release validation expectations.
- External notifier sidecar topology, including that Docker/Compose networks belong to the consuming project rather than the Feature.
