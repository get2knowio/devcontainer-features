# agentsh Policy Reference

The `agentsh` Dev Container Feature builds the active runtime policy from two files:

1. `/usr/local/share/agentsh/security-floor.yaml`
2. The selected project policy, either `/etc/agentsh/policy.yaml` or a workspace overlay

The security floor is always prepended to the selected policy. Rule order matters because agentsh evaluates from top to bottom, so floor rules remain non-overridable even when an overlay is permissive.

## Policy Model

Policies are YAML mappings with rule-list sections such as `file_rules`, `network_rules`, and `command_rules`, plus scalar policy sections such as `env_policy`. The merge helper rejects malformed YAML, unknown top-level keys, rule sections that are not lists, and empty or non-mapping rules.

## Security Floor

The floor contains `deny-agentsh-config-write`. It denies write, create, and delete operations against:

- `**/.devcontainer/**`
- `**/.agentsh/**`
- `/etc/agentsh/**`
- `/run/agentsh/**`
- `/usr/local/share/agentsh/**`
- `/usr/local/bin/agentsh`
- `/usr/local/bin/agentsh-shell-shim`

No feature option disables this floor.

## Overlay

Set `policyOverlayPath` to a workspace-relative YAML file. When the file exists, it replaces the default project policy. When it is absent, the installed example policy is used. A malformed overlay fails container startup.

## Autonomous-Agent Customization

For fully unattended agents, replace `approve` fallback rules with `deny` rules in an overlay. Keep explicit allowlists for required package registries, source hosts, and model APIs.

## Self-Protection Contract

The floor protects agentsh configuration, runtime policy, installed assets, the binary, the shell shim, and project policy locations from in-container modification. This is a boundary inside the devcontainer; host-level administrators and container runtime configuration remain outside the feature's control.

## Threat-Model Boundary

The feature requires at least Landlock-level enforcement. If the runtime cannot provide that level, install or startup fails instead of silently running with minimal shim-only enforcement.

## REST API Exposure

Policy files do not control whether the agentsh REST API is reachable from another
container. The feature keeps the API private by default and only binds it on all container
interfaces when `externalRestApi` is enabled with `restApiKey`.

The agentsh server reads its authoritative configuration from `/etc/agentsh/config.yaml`
(its default `--config` path), which carries the HTTP bind address, API-key auth, and the
`policies.dir`/`policies.default` pointer to the merged runtime policy. When external REST
is enabled, API keys are stored in `/etc/agentsh/api_keys.yaml` as a root-level YAML list of
`{name, key}` entries. Authenticated endpoints (such as `/api/v1/approvals`) require the
`X-API-Key` header; `/health` and `/ready` stay unauthenticated for liveness probes.
