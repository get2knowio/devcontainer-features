<!--
Sync Impact Report
Version change: template -> 1.0.0
Modified principles:
- PRINCIPLE_1_NAME -> I. Feature Contract Fidelity
- PRINCIPLE_2_NAME -> II. Selective, Idempotent Installation
- PRINCIPLE_3_NAME -> III. Cross-Architecture Dev Container Compatibility
- PRINCIPLE_4_NAME -> IV. Testable Feature Changes
- PRINCIPLE_5_NAME -> V. Documentation, Versioning, and Release Readiness
Added sections:
- Feature Scope and Constraints
- Development Workflow and Quality Gates
Removed sections:
- None
Templates requiring updates:
- .specify/templates/plan-template.md: updated
- .specify/templates/spec-template.md: updated
- .specify/templates/tasks-template.md: updated
- .specify/templates/commands/*.md: not present
- .specify/extensions/git/commands/*.md: reviewed, no updates required
Runtime guidance updates:
- README.md: updated
- src/ai-clis/README.md: updated
- src/github-actions-tools/README.md: updated
- src/modern-cli-tools/README.md: updated
- src/python-tools/README.md: updated
- CONTRIBUTING.md: updated
- .github/copilot-instructions.md: updated
Follow-up TODOs:
- None
-->
# get2know.io DevContainer Feature Collection Constitution

## Core Principles

### I. Feature Contract Fidelity
Every feature MUST keep `src/<feature>/devcontainer-feature.json`, `src/<feature>/install.sh`,
tests, examples, and documentation in agreement. Feature IDs, option names, defaults,
supported tool names, version options, `installsAfter`, and documentation URLs are public
contracts once released. Any contract change MUST be intentional, documented, and reflected
in the root README, feature README, tests, and full-stack example when applicable.

Rationale: users consume these features as OCI artifacts, so metadata drift or undocumented
option changes break reproducibility before an installer even runs.

### II. Selective, Idempotent Installation
Installers MUST support the collection's standard `install` whitelist and `omit` blacklist
semantics where a feature exposes multiple tools or tool groups. Installers MUST be safe to
run more than once, use `set -e`, fail on required install errors, and make non-critical
setup failures explicit with warnings. User-scoped setup MUST use `$_REMOTE_USER` and
`$_REMOTE_USER_HOME`; shell configuration MUST target `.zshrc` unless a feature explicitly
documents a broader shell contract.

Rationale: Dev Container Features are frequently rebuilt, composed, and selectively enabled;
repeatable installation behavior is the core user experience.

### III. Cross-Architecture Dev Container Compatibility
Feature installers MUST run on supported Dev Container Linux base images and handle `amd64`
and `arm64` through `dpkg --print-architecture` or an equivalent explicit mapping. Features
that depend on language runtimes MUST declare the relevant upstream Dev Container Feature in
`installsAfter`. Versioned downloads MUST resolve `latest` deterministically at build time or
allow a pinned version option.

Rationale: the collection is intended to compose across standard Dev Container base images,
local Docker runs, and GitHub Actions runners without hidden architecture assumptions.

### IV. Testable Feature Changes
Every behavior-changing feature update MUST include or update Dev Container feature tests
under `test/<feature>/`. New tools or options MUST have scenario coverage for meaningful
selection combinations, and cross-feature interactions MUST update `test/_global/` when the
full-stack composition changes. Tests MUST verify installed commands, configured aliases or
shell setup, option filtering, and version pin behavior when those behaviors are affected.

Rationale: the only reliable proof of a feature is that it installs and works inside the
container images users will build.

### V. Documentation, Versioning, and Release Readiness
Documentation MUST change with the feature contract and installer behavior in the same
change set. Every released feature change MUST increment the affected
`devcontainer-feature.json` version according to semantic versioning: MAJOR for breaking
contracts, MINOR for additive tools or options, and PATCH for fixes or documentation-only
corrections. Release and validation workflows MUST remain aligned with the published feature
set before a change is considered ready.

Rationale: this repository publishes versioned artifacts; users need accurate docs and
predictable version signals to adopt updates safely.

## Feature Scope and Constraints

This project contains Dev Container Features published under
`ghcr.io/get2knowio/devcontainer-features`. Source for each feature lives in `src/<feature>/`
with a required `devcontainer-feature.json` and `install.sh`. Tests live under
`test/<feature>/`, shared composition tests live under `test/_global/`, examples live under
`examples/`, and project-level user guidance lives in `README.md`, `CONTRIBUTING.md`, and
`docs/`.

Feature work MUST stay within this layout unless a plan explicitly justifies a structural
change. Shared installer helpers are allowed only when they reduce real duplication without
obscuring feature-local behavior. Features MUST prefer standard package managers or official
release artifacts for installed tools, and any curl or binary download path MUST validate
architecture, version, and install location explicitly.

## Development Workflow and Quality Gates

Plans MUST pass the Constitution Check before implementation starts and again after design.
The check MUST identify affected feature contracts, installer behavior, supported base
images, architecture handling, test coverage, documentation updates, examples, and version
bumps.

Tasks MUST be organized so each affected feature can be implemented and tested independently.
Behavior-changing tasks MUST include failing-first or newly added tests before installer or
metadata changes are marked complete. Pull requests MUST include the relevant Dev Container
feature test command or a documented reason the test could not be run locally.

Reviewers MUST reject changes that leave metadata, installers, tests, examples, and
documentation inconsistent. Any exception to these gates MUST be recorded in the plan's
Complexity Tracking table with the simpler alternative that was rejected.

## Governance

This constitution supersedes conflicting repository guidance. Amendments require a written
change to this file, a Sync Impact Report, updates to dependent Spec Kit templates and
runtime guidance, and review of any active feature plans affected by the change.

Versioning policy for this constitution:
- MAJOR: Removes or redefines a principle, weakens a quality gate, or introduces a
  backward-incompatible governance rule.
- MINOR: Adds a principle or section, or materially expands compliance requirements.
- PATCH: Clarifies wording, fixes typos, or updates references without changing obligations.

Compliance review is required during `/speckit-plan`, `/speckit-tasks`, implementation
review, and release preparation. The plan's Constitution Check is the authoritative place to
record compliance, justified violations, and follow-up work.

**Version**: 1.0.0 | **Ratified**: 2026-06-01 | **Last Amended**: 2026-06-01
