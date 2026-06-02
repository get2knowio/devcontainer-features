# Feature Specification: Agentsh DevContainer Feature

**Feature Branch**: `001-agentsh-feature`

**Created**: 2026-06-01

**Status**: Draft

**Input**: User description: "Create a public OCI-distributed Dev Container Feature named agentsh that installs agentsh execution-layer security, a shell shim, a security floor, an example policy, overlay support, release automation, tests, and documentation for get2knowio consumers."

## Clarifications

### Session 2026-06-01

- Q: Which OCI namespace is canonical for the published agentsh feature? → A: `ghcr.io/get2knowio/devcontainer-features/agentsh:0.1.0`
- Q: How are approval requests delivered? → A: agentsh-native payloads served asynchronously over the agentsh REST API (`/api/v1/approvals`); no outbound webhook
- Q: Which shells must the feature shim by default? → A: `/bin/bash` and `/bin/sh`
- Q: What minimum enforcement level is acceptable for a successful install/start? → A: Landlock-level enforcement or stronger
- Q: Which CPU architectures must release validation cover? → A: both amd64 and arm64

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add agentsh to a devcontainer (Priority: P1)

A project author adds the agentsh feature to a project's devcontainer configuration and rebuilds the container. On first start, agentsh is installed, policy enforcement is active, approval requests are routed to the configured host notifier, and common sensitive actions are blocked or approved according to the default policy.

**Why this priority**: This is the core value of the feature: project authors get a reusable, spec-compliant way to deploy agentsh into any compatible devcontainer without copying bespoke setup scripts.

**Independent Test**: Build a devcontainer that references the feature with default options, enter the container, confirm enforcement is active, confirm sensitive local actions are denied, and confirm unknown network access raises an approval request.

**Acceptance Scenarios**:

1. **Given** a project devcontainer references the agentsh feature with default options, **When** the container is built and started, **Then** agentsh is available, both bash and sh shell paths are mediated, enforcement status can be inspected, and the default policy is active.
2. **Given** the default policy is active, **When** a process attempts to read SSH private key material or dump the full environment, **Then** the operation is denied with a clear agentsh policy result.
3. **Given** approvals are enabled, **When** a process accesses a domain outside the default allowlist, **Then** agentsh creates a pending approval (retrievable over its REST API) and fails secure (deny) if it is not resolved within the configured timeout.

---

### User Story 2 - Customize project policy safely (Priority: P2)

A project author supplies a project-level agentsh policy overlay to replace the default project posture while keeping platform self-protection intact. The active runtime policy uses the custom project rules plus the non-overridable security floor.

**Why this priority**: Real projects need different allowlists, environment-variable access, and approval gates. Customization must not let users accidentally remove the rules that keep agentsh itself protected.

**Independent Test**: Add a custom overlay that permits a domain denied by the default policy, restart the container, confirm the custom behavior is active, and confirm writes to agentsh configuration, policy, binary, shim, and overlay paths are still denied.

**Acceptance Scenarios**:

1. **Given** a valid overlay exists at the documented project path, **When** the container starts, **Then** agentsh uses the overlay as the project policy input and logs that the overlay was selected.
2. **Given** the overlay contains permissive file rules and omits self-protection rules, **When** a process attempts to modify agentsh policy, binary, shim, or overlay files, **Then** the write is denied because the security floor takes precedence.
3. **Given** the overlay allows a domain outside the default allowlist, **When** a process accesses that domain, **Then** the access succeeds according to the overlay rather than the default policy.

---

### User Story 3 - Release and consume the feature publicly (Priority: P3)

A repository maintainer can validate, document, and publish the agentsh feature as a versioned OCI artifact. Consumers can discover the feature, read its options, and pin a known feature release.

**Why this priority**: The feature is intended to be the canonical get2knowio distribution path for agentsh in devcontainers, so release quality and public documentation must be part of the first usable version.

**Independent Test**: Run the feature test suite, tag a release, verify the release workflow publishes the expected artifact tags, and confirm generated documentation matches the feature contract.

**Acceptance Scenarios**:

1. **Given** a pull request changes the feature contract or installer behavior, **When** validation runs, **Then** smoke tests, scenario tests, and shell script checks run before merge.
2. **Given** a release tag is pushed, **When** the release workflow completes, **Then** the agentsh feature is published to `ghcr.io/get2knowio/devcontainer-features/agentsh` with the release version and latest tag.
3. **Given** documentation is generated or updated, **When** a consumer reads the root and feature README files, **Then** they can find the feature URI, options, default webhook behavior, customization path, and troubleshooting guidance.

### Edge Cases

- No approver resolves a pending approval; approval-required actions must fail secure after the configured timeout.
- The project overlay exists but is malformed or schema-incompatible; the container must fail to start clearly rather than silently using the default policy.
- The security floor file is missing or malformed; the container must fail to start because self-protection cannot be guaranteed.
- The container runs on a host or runtime with reduced kernel/security capabilities; if agentsh cannot provide at least Landlock-level enforcement, the build or start must fail clearly rather than running without meaningful enforcement.
- An external notifier sidecar resolves approvals by polling the authenticated REST API; the consuming project is responsible for the shared network and API key.
- A project devcontainer defines conflicting runtime security flags; documentation must identify that project-level settings can affect enforcement.
- The requested agentsh release, architecture, or libc variant is unavailable; the build must fail with a clear error.
- The feature is rebuilt or installer steps are re-run; repeated execution must not corrupt the shell shim, policy files, or configuration.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST provide a public Dev Container Feature named `agentsh` that can be referenced by spec-compliant devcontainer tools through the canonical OCI feature URI `ghcr.io/get2knowio/devcontainer-features/agentsh`.
- **FR-002**: The feature MUST expose a public option contract for the agentsh release version, approval timeout, non-interactive shim forcing, shell-shim installation, development dependency installation, project policy overlay path, and external REST API exposure (enable flag, port, API key).
- **FR-003**: The feature MUST default to a pinned agentsh release version for the first release and require deliberate feature releases to change that pin.
- **FR-004**: The feature MUST install agentsh inside the devcontainer without modifying the host system or bundling the agentsh binary in the feature artifact.
- **FR-005**: The feature MUST install and activate agentsh shell shims for both `/bin/bash` and `/bin/sh` so shell-driven and non-interactive agent workflows are mediated by agentsh.
- **FR-006**: The feature MUST provide a default project policy that is usable when no project overlay is supplied and readable as the canonical example for customization.
- **FR-007**: The feature MUST provide a platform-managed security floor that is always applied before project policy rules and cannot be disabled or overridden by feature options or user overlays.
- **FR-008**: The security floor MUST protect agentsh configuration, generated runtime policy, platform-managed policy assets, the agentsh binary, the shell shim, and the documented project overlay path from writes, creates, and deletes by processes inside the devcontainer.
- **FR-009**: When a valid project overlay exists at the configured path, the feature MUST use that overlay as the project policy input instead of the default policy while still applying the security floor.
- **FR-010**: When no project overlay exists, the feature MUST use the installed default policy while still applying the security floor.
- **FR-011**: When the project overlay or security floor is invalid, the container MUST fail to start with a clear error before agentsh begins enforcing an unintended policy.
- **FR-012**: The feature MUST enable agentsh approvals so that policy `decision: approve` rules create pending approvals served asynchronously over the agentsh REST API, honor the configured timeout, and fail secure (deny) when no approver resolves them.
- **FR-013**: The feature MUST support common Linux devcontainer base images across Debian/Ubuntu and Alpine families and across amd64 and arm64 architectures where upstream agentsh releases are available, and MUST fail clearly if the runtime cannot provide at least Landlock-level enforcement.
- **FR-014**: The feature MUST declare the runtime capabilities and mounts required for the strongest available agentsh enforcement mode in a spec-compliant way.
- **FR-015**: The feature MUST verify at build time that agentsh is installed, reports its version, and can detect an available enforcement mode.
- **FR-016**: The feature MUST include tests covering default install behavior, project overlay behavior, security-floor self-protection, supported base-image families, amd64 and arm64 release validation, and release-blocking script quality checks.
- **FR-017**: The feature MUST publish release artifacts only after validation succeeds and MUST document `ghcr.io/get2knowio/devcontainer-features/agentsh` as the canonical feature URI with versioning expectations.
- **FR-018**: The feature MUST NOT include Telegram, notifier credentials, direct chat transport logic, runtime policy switching, live reload, signed-policy enforcement, audit forwarding, prebuilt images, or multiple baseline policies in the first release.
- **FR-019**: The feature documentation MUST explain how policy approvals are served over the REST API and resolved by a notifier sidecar (and the fail-secure behavior when none is attached), degraded enforcement modes, overlay customization patterns, and the non-overridable security floor.
- **FR-020**: The feature MUST keep metadata, installer behavior, tests, examples, documentation, and versioning aligned in the same change set for any contract or behavior change.

### Feature Contract & Compatibility *(mandatory for Dev Container feature changes)*

- **Affected Features**: New `src/agentsh` feature; no existing feature behavior is intentionally changed.
- **Public Contract Changes**: New feature ID `agentsh`; first feature version `0.1.0`; canonical OCI URI `ghcr.io/get2knowio/devcontainer-features/agentsh`; options for `version`, `approvalTimeoutSeconds`, `shimForceNonTty`, `installShellShims`, `installDevDependencies`, `policyOverlayPath`, `externalRestApi`, `restPort`, and `restApiKey`; public documentation URL under the get2knowio Dev Container Features repository; runtime metadata for environment, capabilities, security options, mounts, dependency ordering, and startup behavior.
- **Installer Semantics**: The installer must be idempotent, use strict failure behavior for required steps, support Debian/Ubuntu and Alpine dependency installation, install user-visible policy assets, activate the shell shim, verify agentsh, and print a concise build summary. The agentsh feature does not use the collection-wide `install`/`omit` tool-selection pattern because it installs one cohesive security product rather than a selectable tool group.
- **Compatibility Targets**: Linux devcontainers using spec-compliant consumers including deacon, VS Code Dev Containers, GitHub Codespaces, JetBrains IDEs, and Ona; amd64 and arm64 validated before release; glibc and musl release variants where available; Docker bridge defaults with documented overrides for Podman, Docker Desktop, hosted sandboxes, and other non-default networks.
- **Documentation & Examples**: Root README feature table, feature README, policy reference documentation, example consumer devcontainer configuration, security floor explanation, overlay customization recipes, troubleshooting guidance, and release/publish workflow documentation must be present and consistent.

### Key Entities *(include if feature involves data)*

- **Dev Container Feature**: The published feature contract consumers reference to install agentsh into a devcontainer.
- **Feature Option Contract**: The configurable values exposed to consumers, including agentsh version, approval routing, timeout, instance identity, shim behavior, dependency installation, and overlay path.
- **Default Policy**: The user-side policy installed by the feature and used when a project does not provide an overlay.
- **Security Floor**: The non-negotiable platform rule set that protects agentsh's threat model and is always applied ahead of project policy rules.
- **Project Overlay**: A project-owned policy file that replaces the default project posture while remaining subject to the security floor.
- **Active Runtime Policy**: The effective policy used by agentsh after combining the security floor with either the default policy or project overlay.
- **Approval Request**: An agentsh-native runtime decision request created when a policy rule requires human approval, served asynchronously over the agentsh REST API.
- **Release Artifact**: The versioned OCI feature artifact published at `ghcr.io/get2knowio/devcontainer-features/agentsh` for consumers to pin and install.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A project author can add the feature to a clean devcontainer configuration and complete a successful build and first start in one documented pass.
- **SC-002**: The default-policy test suite verifies that agentsh is installed, enforcement is detectable, sensitive file reads are denied, bulk environment dumps are denied, and unknown network access produces an agentsh-native approval request.
- **SC-003**: The overlay test suite verifies that a project-specific overlay changes project posture while preserving every security-floor protection.
- **SC-004**: The self-protection test suite verifies that attempts to modify the project overlay, installed policies, generated runtime policy, agentsh binary, shell shim, and platform-managed agentsh assets are denied even under a permissive overlay.
- **SC-005**: Feature validation passes across Ubuntu, Debian, and Alpine base-image scenarios on both amd64 and arm64 for default behavior and meaningful customization scenarios, and fails clearly in any scenario where at least Landlock-level enforcement is unavailable.
- **SC-006**: Release validation publishes the first feature release with a versioned tag and a latest tag only after tests and script quality checks pass.
- **SC-007**: Documentation enables a first-time consumer to identify the feature URI, configure the webhook for their runtime, understand the security floor, and create a custom overlay without consulting source code.
- **SC-008**: A malformed overlay causes startup failure with a clear policy error in 100% of tested cases.
- **SC-009**: The feature never requires notifier credentials, Telegram configuration, or host modification to be present in the devcontainer feature configuration.

## Assumptions

- This specification is for the existing get2knowio Dev Container Features repository layout, with `agentsh` added as a new feature under the multi-feature repository model.
- Planning verified `0.20.2` as the latest stable agentsh release on 2026-06-01; implementation must re-check immediately before release and pin the newest compatible non-prerelease version.
- Approvals are served over the agentsh REST API and resolved by an optional, generic external notifier sidecar that polls `/api/v1/approvals`; this feature does not push approvals to any external URL or wrap them in a notifier-specific payload.
- The security floor is merged with the selected user policy on every container start; user-level policy extension beyond "overlay replaces default project posture" is out of scope for the first release.
- Users who need autonomous-agent-only posture will customize the default example by replacing approval fallback rules with deny rules rather than selecting a second shipped baseline.
- Linux devcontainers are the only target for the first release.
