# Research: Agentsh DevContainer Feature

## Decision: Publish under `ghcr.io/get2knowio/devcontainer-features/agentsh`

**Rationale**: The Dev Container authoring guide states feature references are prefixed with
the owner/repository namespace, for example `ghcr.io/devcontainers/feature-starter/color:1`,
and collection index entries point at the repository namespace root. This matches the
existing get2knowio repository name and the clarification decision.

**Alternatives considered**:
- `ghcr.io/get2knowio/features/agentsh`: rejected because it conflicts with the selected
  repository namespace and would add release/docs drift.
- Dual publishing: rejected for v0.1.0 because one canonical URI is easier to test and
  document.

**Sources**:
- [Authoring a Dev Container Feature](https://containers.dev/guide/author-a-feature)
- [Dev Container Features reference](https://containers.dev/implementors/features/)

## Decision: Pin the first release to latest stable agentsh, currently `0.20.2`

**Rationale**: The agentsh website currently shows `0.20.3` install examples, but the GitHub
releases page marks `v0.20.2` as the latest stable release and shows `v0.20.3-rc*` as
prereleases. The feature should not pin to an RC for a public first release unless the user
explicitly changes the release policy during implementation. Implementation must re-check
this immediately before release and move to a newer non-prerelease if one is available.

**Alternatives considered**:
- Pin `0.20.3`: rejected during planning because the public GitHub release page currently
  shows only release candidates for 0.20.3.
- Track `latest`: rejected by the feature spec because upstream changes could alter shim or
  policy behavior without a deliberate feature release.

**Sources**:
- [agentsh releases](https://github.com/canyonroad/agentsh/releases)
- [agentsh install docs](https://www.agentsh.org/)

## Decision: Use agentsh security mode `auto` with `minimum_mode: landlock`

**Rationale**: agentsh documents security modes where `full` requires seccomp, eBPF, and
FUSE; `landlock` and `landlock-only` provide kernel-enforced protection; and `minimal` is
shim/capability-only. The clarified spec requires at least Landlock-level enforcement, so
the server config should fail startup if auto-detection falls below Landlock-level
protection.

**Alternatives considered**:
- Allow minimal mode with warnings: rejected because it would violate the clarified
  acceptance criteria and create a false sense of protection.
- Force `full`: rejected because common devcontainer runtimes may not permit full seccomp
  user-notify; Landlock-level is the minimum contract.

**Sources**:
- [agentsh docs: security modes](https://www.agentsh.org/docs/)

## Decision: Install agentsh from upstream release assets at build time

**Rationale**: The feature must not bundle the agentsh binary. Debian/Ubuntu can use package
assets where available; Alpine/musl must use the musl tarball; all paths must validate the
architecture and libc family before selecting an asset. The install script must fail clearly
when the requested version lacks the required asset or checksum/digest.

**Alternatives considered**:
- Build from source: rejected for v0.1.0 because it expands toolchain dependencies and
  makes builds slower and less reproducible.
- Bundle binaries in the feature: rejected by scope and licensing/distribution constraints.

**Sources**:
- [agentsh install docs](https://www.agentsh.org/)

## Decision: Implement policy composition as floor-prepended overlay replacement

**Rationale**: The project policy choice is default vs. overlay. The security floor is always
prepended to the chosen user policy so first-match-wins policy sections protect agentsh
config, runtime policy, binaries, shim, and overlay paths even if the overlay is permissive.
This keeps the user model simple while preserving platform invariants.

**Alternatives considered**:
- Full user policy extension/merge semantics: rejected for v0.1.0 because it increases
  ambiguity and was explicitly parked for later.
- Put self-protection only in the example policy: rejected because users could accidentally
  remove load-bearing rules.

## Decision: Serve approvals over the agentsh REST API (no outbound webhook)

**Rationale**: agentsh 0.20.2 has no approval-push webhook. Approvals are created by policy
`decision: approve` rules and served asynchronously over the agentsh REST API
(`/api/v1/approvals`); a notifier sidecar resolves them by polling that authenticated
endpoint. The feature therefore enables approvals and exposes the REST API (privately by
default, externally only when `externalRestApi` + `restApiKey` are set) rather than
configuring an outbound webhook URL.

**Alternatives considered**:
- An `approvalWebhookUrl` option pushing payloads to a notifier: rejected/removed because
  agentsh does not push approvals, so the option had no effect.
- Transform to a notifier-specific payload: rejected because it couples this feature to one
  notifier implementation and duplicates notifier responsibility.

## Decision: Use `devcontainers/action` and `devcontainer features test`

**Rationale**: The Dev Container action is the upstream action for packaging, publishing, and
generating docs for Features, and it is already used by the reference feature collection.
The repository already uses the Dev Container CLI test harness, so `agentsh` should extend
that pattern rather than introducing a separate feature test system.

**Alternatives considered**:
- Custom Docker-only tests: rejected because they would not exercise the spec feature
  installation path.
- Deacon authoring commands: rejected because deacon is a consumer, not an authoring tool,
  for this feature.

**Sources**:
- [devcontainers/action README](https://github.com/devcontainers/action)
- [Authoring a Dev Container Feature](https://containers.dev/guide/author-a-feature)
