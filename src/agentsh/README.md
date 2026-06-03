# agentsh

Installs [agentsh](https://github.com/canyonroad/agentsh) execution-layer security in a devcontainer with shell shims, a default project policy, a non-overridable security floor, and policy-based approvals served over the agentsh REST API.

## Usage

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/agentsh:0.1.0": {}
  }
}
```

The installer downloads the pinned upstream agentsh Linux release at build time, verifies its checksum manifest entry, installs `/usr/local/bin/agentsh`, swaps `/bin/bash` and `/bin/sh` through `/usr/local/bin/agentsh-shell-shim` (unless `installShellShims` is `false`), and writes startup configuration under `/etc/agentsh`. The agentsh server reads its authoritative configuration from `/etc/agentsh/config.yaml` at startup.

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `0.20.2` | Pinned upstream agentsh stable release without `v`. |
| `approvalTimeoutSeconds` | string | `"300"` | Wait before an approval-required action fails secure (deny). |
| `shimForceNonTty` | boolean | `true` | Enables non-interactive shell shim forcing through `AGENTSH_SHIM_FORCE=1`. |
| `installShellShims` | boolean | `true` | Replaces `/bin/sh` and `/bin/bash` with the agentsh shim so every shell invocation is mediated. Keep `true` for the secure default. See [Validation Option: installShellShims](#validation-option-installshellshims). |
| `installDevDependencies` | boolean | `true` | Installs required OS packages on Debian, Ubuntu, and Alpine images. |
| `policyOverlayPath` | string | `.devcontainer/agentsh-policy.yaml` | Workspace-relative overlay policy path. |
| `externalRestApi` | boolean | `false` | Bind the agentsh REST API on all container interfaces for an external notifier sidecar. Requires `restApiKey`. |
| `restPort` | string | `"18080"` | Port for the agentsh REST API. |
| `restApiKey` | string | `""` | API key for REST clients. Required when `externalRestApi` is `true`. |

## Default Behavior

On container startup, `/usr/local/share/agentsh/start-server.sh` merges:

1. `/usr/local/share/agentsh/security-floor.yaml`
2. `/etc/agentsh/policy.yaml`, unless `policyOverlayPath` exists in the workspace

The merged policy is written to `/run/agentsh/policy.yaml`, then `agentsh server --config /etc/agentsh/config.yaml` starts if it is not already running. Startup logs include the resolved workspace root, `source=default` or `source=overlay:<path>`, and the security floor path.

The default policy allows common workspace development, package registries, GitHub, and model APIs. It denies SSH/private credential access, bulk environment dumps, and dangerous system commands, then routes unknown network access to an approval decision.

## Validation Option: installShellShims

`installShellShims` defaults to `true`, which is the secure production posture: agentsh replaces `/bin/sh` and `/bin/bash` (preserving the originals as `/bin/sh.real` and `/bin/bash.real`) so every shell invocation is mediated.

Set it to `false` only for validation or advanced scenarios. When `false`, agentsh, the policy assets, `/etc/agentsh/config.yaml`, the runtime policy merge, and the `/usr/local/bin/agentsh-shell-shim` binary are all still installed, but `/bin/sh` and `/bin/bash` are left unmodified.

The primary use is automated testing: the Dev Container test harness (`devcontainer features test`) bootstraps every container through `/bin/sh`, so it cannot start a container whose `/bin/sh` is the agentsh shim. The repository's scenario tests therefore set `installShellShims: false`, while real shim mediation is validated separately by the Docker integration test under `test/agentsh/integration/`.

Disabling shell shims is **not** a recommended runtime security posture, because non-shim agent subprocesses can then bypass shell-level mediation.

## External Notifier Sidecars

By default, the REST API binds to `127.0.0.1:18080` and is private to the devcontainer. Enable `externalRestApi` only when another container needs to poll agentsh events or approvals.

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/agentsh:0.1.0": {
      "externalRestApi": true,
      "restApiKey": "replace-with-a-generated-secret"
    }
  }
}
```

When enabled, the feature renders `server.http.addr: "0.0.0.0:18080"` in `/etc/agentsh/config.yaml` and requires API-key authentication with the `X-API-Key` header. The API key is written to `/etc/agentsh/api_keys.yaml` (mode `0600`) as a root-level YAML list of `{name, key}` entries, which is the shape agentsh expects:

```yaml
- name: "external-notifier"
  key: "replace-with-a-generated-secret"
```

Authenticated API endpoints (for example `/api/v1/approvals`, which a notifier sidecar polls for pending approvals) return `401` without a valid `X-API-Key` and `200` with the configured key. The `/health` and `/ready` endpoints stay unauthenticated for liveness probes.

Dev Container Features cannot create Docker networks or attach sidecars to them. Put the devcontainer and notifier on a shared network in the consuming project, usually with Docker Compose:

```yaml
services:
  devcontainer:
    image: mcr.microsoft.com/devcontainers/base:ubuntu
    networks: [agentsh-notifier]

  notifier:
    image: example/notifier:latest
    environment:
      AGENTSH_SERVER: "http://devcontainer:18080"
      AGENTSH_API_KEY: "replace-with-the-same-generated-secret"
    networks: [agentsh-notifier]

networks:
  agentsh-notifier:
    internal: true
```

If `restPort` is changed, sidecars should use `http://<devcontainer-service-name>:<restPort>`. The feature also writes `/etc/profile.d/agentsh.sh` for interactive in-container clients, but `containerEnv.AGENTSH_SERVER` remains the static default because Dev Container Feature metadata cannot interpolate option values.

## Approvals

Policy rules with `decision: approve` create a pending approval that agentsh serves
asynchronously over its REST API. An external notifier sidecar resolves them by polling the
authenticated `/api/v1/approvals` endpoint (see [External Notifier Sidecars](#external-notifier-sidecars)).
If no approver responds within `approvalTimeoutSeconds`, the action fails secure (deny).

With no notifier attached, approval-required actions simply time out and are denied, which is
the secure default. There is no outbound approval webhook: agentsh does not push approval
requests to an external URL.

## Security Floor

The security floor denies write, create, and delete access to agentsh-managed files and the documented project policy locations:

- `**/.devcontainer/**`
- `**/.agentsh/**`
- `/etc/agentsh/**`
- `/run/agentsh/**`
- `/usr/local/share/agentsh/**`
- `/usr/local/bin/agentsh`
- `/usr/local/bin/agentsh-shell-shim`

The floor is always prepended to the selected project policy and cannot be disabled by feature options or overlays.

## Overlay Recipes

Allow one extra domain while denying other unknown network access:

```yaml
network_rules:
  - name: allow-example
    domains: ["example.com"]
    ports: [443]
    decision: allow
  - name: deny-other-network
    decision: deny
```

Use approval for deletes in the workspace:

```yaml
file_rules:
  - name: approve-workspace-delete
    paths: ["/workspace/**", "/workspaces/**"]
    operations: [delete]
    decision: approve
```

Run autonomous agents with no human approval dependency:

```yaml
network_rules:
  - name: allow-required-apis
    domains: ["api.openai.com", "github.com", "api.github.com"]
    ports: [443]
    decision: allow
  - name: deny-other-network
    decision: deny
```

Hide selected environment variables from governed commands:

```yaml
env_policy:
  deny:
    - "AWS_SECRET_ACCESS_KEY"
    - "GITHUB_TOKEN"
```

## Minimum Enforcement

The feature requires `agentsh detect` to report Landlock-level or stronger enforcement. If the container runtime cannot provide that, install or startup fails instead of running with minimal shim-only protection.

Project-level runtime flags can affect enforcement. Keep the feature's `capAdd`, `securityOpt`, and `/dev/fuse` mount declarations unless you intentionally validate a different agentsh mode.

## Troubleshooting

### Download or Checksum Failure

Confirm the selected `version` exists in `canyonroad/agentsh` releases and includes a Linux asset plus checksum entry for the container architecture and libc family.

### Startup Fails on Overlay

Run:

```bash
/usr/local/share/agentsh/merge-policy.py /usr/local/share/agentsh/security-floor.yaml .devcontainer/agentsh-policy.yaml
```

The merge helper reports invalid YAML, unknown top-level keys, malformed rule lists, and missing files.

### Approvals Never Resolve

Approval-required actions wait `approvalTimeoutSeconds` and then fail secure (deny). To
resolve them interactively, attach a notifier sidecar that polls the authenticated
`/api/v1/approvals` endpoint (see [External Notifier Sidecars](#external-notifier-sidecars)),
or replace `approve` rules with explicit `allow`/`deny` rules in an overlay.

### External REST API Rejected at Build Time

`externalRestApi` requires `restApiKey`. Keep this API private to a trusted Compose network and rotate the key if it is exposed.

## Release Notes

The first feature release publishes `ghcr.io/get2knowio/devcontainer-features/agentsh:0.1.0` and `latest` after validation. Keep `version` pinned to a stable upstream agentsh release and bump the feature version when changing installer behavior, policy contract, options, or release defaults.
