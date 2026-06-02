# Data Model: Agentsh DevContainer Feature

## Dev Container Feature

**Purpose**: Public installable unit consumed from `devcontainer.json`.

**Fields**:
- `id`: fixed string `agentsh`
- `version`: feature release version, starting at `0.1.0`
- `name`: display name
- `description`: summary of agentsh installation and approval routing behavior
- `documentationURL`: feature README URL
- `options`: Feature Option Contract
- `containerEnv`: runtime environment variables required by agentsh clients/shim
- `capAdd`: runtime capability declarations
- `securityOpt`: runtime security option declarations
- `mounts`: runtime device mounts
- `installsAfter`: upstream feature dependencies
- `entrypoint`: container startup script path

**Validation Rules**:
- `id` remains stable after release.
- `version` follows semantic versioning.
- `documentationURL` points to `src/agentsh`.
- Metadata options match installer environment variable handling and documentation.
- Runtime metadata remains consistent with minimum Landlock-level enforcement requirements.

## Feature Option Contract

**Purpose**: User-configurable values supplied through devcontainer feature options.

**Fields**:
- `version`: pinned agentsh release version without `v` prefix; initial planned stable
  default `0.20.2` unless a newer stable release is verified before implementation release
- `approvalTimeoutSeconds`: numeric timeout before an approval-required action fails secure
  (deny); default `300`; maps to `config.yaml` `approvals.timeout`
- `shimForceNonTty`: boolean; default `true`
- `installShellShims`: boolean; default `true`; when false, install everything but leave
  `/bin/sh` and `/bin/bash` unmodified
- `installDevDependencies`: boolean; default `true`
- `policyOverlayPath`: project-relative overlay path; default
  `.devcontainer/agentsh-policy.yaml`
- `externalRestApi`: boolean; default `false`; when true, REST binds on all container
  interfaces for a sidecar notifier
- `restPort`: numeric REST API port; default `18080`
- `restApiKey`: optional API key; required when `externalRestApi` is true

**Validation Rules**:
- Approvals are policy-driven (`decision: approve`) and served over the agentsh REST API; an
  unresolved approval must fail secure (deny) after `approvalTimeoutSeconds`.
- `approvalTimeoutSeconds` must be positive.
- `policyOverlayPath` must resolve under the workspace root.
- `externalRestApi` must not be enabled without `restApiKey`.
- `version` must map to available upstream Linux assets for the detected libc and CPU
  architecture.

## Default Policy

**Purpose**: User-side policy used when a project overlay is absent and shown as the example
for customization.

**Fields**:
- `file_rules`: development access and secret/config denial examples
- `network_rules`: package registry, GitHub, model API allowlist plus approval fallback
- `command_rules`: denial/approval rules for risky commands
- `env_policy`: environment denylist/visibility controls supported by the pinned release

**Validation Rules**:
- Does not duplicate security-floor self-protection rules.
- Is valid agentsh policy syntax for the pinned agentsh release.
- Works as a complete policy when merged with the security floor.

## Security Floor

**Purpose**: Non-overridable platform invariant rules.

**Fields**:
- `file_rules`: includes `deny-agentsh-config-write`
- Protected paths:
  - `**/.devcontainer/**`
  - `**/.agentsh/**`
  - `/etc/agentsh/**`
  - `/run/agentsh/**`
  - `/usr/local/share/agentsh/**`
  - `/usr/local/bin/agentsh`
  - `/usr/local/bin/agentsh-shell-shim`
- Protected operations: `write`, `create`, `delete`
- Decision: `deny`

**Validation Rules**:
- Floor is always prepended ahead of user policy sections.
- Floor cannot be disabled by option or overlay.
- Missing or invalid floor fails container startup.

## Project Overlay

**Purpose**: Project-owned replacement for the default user-side policy.

**Fields**:
- Same policy sections as Default Policy, according to upstream agentsh policy syntax
- Path resolved from `policyOverlayPath`

**Validation Rules**:
- If absent, default policy is used.
- If present and valid, replaces default policy as the user policy input.
- If present and invalid, container startup fails.
- Overlay remains subject to the security floor.

## Active Runtime Policy

**Purpose**: Effective policy consumed by agentsh server.

**Fields**:
- Merged policy sections written to `/run/agentsh/policy.yaml`
- Source marker logged as `default` or `overlay:<path>`
- Floor path logged for auditability

**State Transitions**:
- `NotGenerated` -> `GeneratedFromDefault` when no overlay exists and merge succeeds
- `NotGenerated` -> `GeneratedFromOverlay` when overlay exists and merge succeeds
- `NotGenerated` -> `Invalid` when floor or selected user policy fails validation
- `Generated*` -> `Regenerated` on container restart

## Approval Request

**Purpose**: Runtime human approval decision created by a policy `decision: approve` rule and
served asynchronously over the agentsh REST API.

**Fields**:
- agentsh-native decision payload
- pending state retrievable from `/api/v1/approvals`
- timeout

**Validation Rules**:
- Payload is not translated or wrapped into a notifier-specific schema.
- An unresolved approval fails secure (deny) after `approvalTimeoutSeconds`.
- There is no outbound approval webhook; resolution is pull-based via the REST API.

## Release Artifact

**Purpose**: Published OCI artifact consumers pin in `devcontainer.json`.

**Fields**:
- Registry namespace `ghcr.io/get2knowio/devcontainer-features`
- Feature name `agentsh`
- Version tag `0.1.0`
- `latest` tag after release validation
- Generated documentation metadata

**Validation Rules**:
- Release requires passing tests and shellcheck.
- amd64 and arm64 validation is required before publish.
- Public documentation matches metadata and installer behavior.
