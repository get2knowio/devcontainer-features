# Tasks: Agentsh DevContainer Feature

**Input**: Design documents from `/specs/001-agentsh-feature/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Required. This is behavior-changing Dev Container feature work with security-sensitive installer, runtime policy, and release behavior.

**Organization**: Tasks are grouped by user story so the default install path, overlay customization, and public release readiness can be validated independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to
- Every task includes an exact file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the new feature skeleton and shared docs/test locations.

- [X] T001 Create `src/agentsh/`, `src/agentsh/scripts/`, `src/agentsh/policies/`, and `test/agentsh/` directories
- [X] T002 [P] Create initial `src/agentsh/devcontainer-feature.json` with id `agentsh`, version `0.1.0`, canonical documentation URL, runtime metadata, and all feature options from `specs/001-agentsh-feature/contracts/feature-contract.md`
- [X] T003 [P] Create placeholder executable `src/agentsh/install.sh` with bash strict mode and option environment variable parsing stubs
- [X] T004 [P] Create placeholder executable `src/agentsh/scripts/start-server.sh` with bash strict mode and runtime path constants
- [X] T005 [P] Create placeholder executable `src/agentsh/scripts/merge-policy.py` with argument parsing for floor policy and user policy paths
- [X] T006 [P] Create initial `src/agentsh/README.md` with feature URI, option table, security floor summary, webhook override summary, and troubleshooting headings
- [X] T007 [P] Create initial `docs/policy-reference.md` with policy model, security floor, overlay, and autonomous-agent customization headings
- [X] T008 [P] Create initial `examples/agentsh.devcontainer.json` referencing `ghcr.io/get2knowio/devcontainer-features/agentsh:0.1.0`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define shared policy/configuration assets and validation helpers required by all user stories.

**CRITICAL**: No user story work can begin until this phase is complete.

- [X] T009 Create `src/agentsh/policies/security-floor.yaml` with the `deny-agentsh-config-write` rule from `specs/001-agentsh-feature/contracts/policy-contract.md`
- [X] T010 Create `src/agentsh/policies/example.yaml` with default file, network, command, and environment rules excluding security-floor self-protection rules
- [X] T011 Implement list-prepending policy merge behavior in `src/agentsh/scripts/merge-policy.py`
- [X] T012 Add YAML syntax, known top-level key, list-section, and malformed-rule validation to `src/agentsh/scripts/merge-policy.py`
- [X] T013 Add policy merge smoke checks for floor+default, floor+overlay, malformed overlay, and missing floor behavior in `test/agentsh/policy_merge_test.sh`
- [X] T014 Add `test/agentsh/scenarios.json` with default, custom-overlay, self-protection, malformed-overlay, missing-floor, no-webhook, ubuntu, debian, and alpine scenarios
- [X] T015 [P] Add scenario fixture policy files under `test/agentsh/fixtures/` for permissive overlay, example.com overlay, malformed overlay, and deny-network overlay
- [X] T016 Update `README.md` feature table to include the new `agentsh` feature and canonical URI

**Checkpoint**: Policy assets, merge mechanics, and scenario definitions are ready for story implementation.

---

## Phase 3: User Story 1 - Add agentsh to a devcontainer (Priority: P1) MVP

**Goal**: A project author can add the feature to a devcontainer, build/start it, and get default agentsh enforcement with webhook approvals.

**Independent Test**: Build the default agentsh feature scenario, verify agentsh is installed, bash and sh are mediated, default policy/server config exist, enforcement is at least Landlock-level, sensitive actions are denied, and unknown network access emits an agentsh-native approval request.

### Tests for User Story 1

- [X] T017 [P] [US1] Add default install assertions for agentsh version, `/usr/local/bin/agentsh`, `/etc/agentsh/policy.yaml`, `/etc/agentsh/config.yaml`, and `/run/agentsh/policy.yaml` in `test/agentsh/test.sh`
- [X] T018 [P] [US1] Add shell shim assertions for `/bin/bash` and `/bin/sh` mediation in `test/agentsh/test.sh`
- [X] T019 [P] [US1] Add enforcement assertion requiring Landlock-level or stronger `agentsh detect` output in `test/agentsh/default.sh`
- [X] T020 [P] [US1] Add default policy denial assertions for SSH private key access and bulk environment dump in `test/agentsh/default.sh`
- [X] T021 [P] [US1] Add mock approval webhook assertion for agentsh-native unknown-network approval requests in `test/agentsh/default.sh`

### Implementation for User Story 1

- [X] T022 [US1] Implement architecture and libc detection for amd64, arm64, glibc, and musl in `src/agentsh/install.sh`
- [X] T023 [US1] Implement Debian/Ubuntu and Alpine prerequisite installation controlled by `INSTALLDEVDEPENDENCIES` in `src/agentsh/install.sh`
- [X] T024 [US1] Implement pinned stable agentsh release asset selection and download for `VERSION` in `src/agentsh/install.sh`
- [X] T025 [US1] Implement checksum or release digest verification for downloaded agentsh assets in `src/agentsh/install.sh`
- [X] T026 [US1] Install `/usr/local/bin/agentsh` mode `0755` idempotently in `src/agentsh/install.sh`
- [X] T027 [US1] Install bash and sh agentsh shell shims with non-TTY forcing controlled by `SHIMFORCENONTTY` in `src/agentsh/install.sh`
- [X] T028 [US1] Copy default policy, security floor, start script, and merge script to their installed container paths with required modes in `src/agentsh/install.sh`
- [X] T029 [US1] Render the agentsh server config with `/run/agentsh/policy.yaml`, approval settings, timeout, and Landlock minimum enforcement in `src/agentsh/install.sh` (later consolidated to the authoritative `/etc/agentsh/config.yaml` and the approval webhook removed — see T070/T071)
- [X] T030 [US1] Implement build-time `agentsh --version` and `agentsh detect` verification with clear failure below Landlock-level enforcement in `src/agentsh/install.sh`
- [X] T031 [US1] Implement startup merge, policy source logging, agentsh server idempotent start, and final `exec "$@"` behavior in `src/agentsh/scripts/start-server.sh`
- [X] T032 [US1] Document default install behavior, first consumer example, webhook default, shell shims, and minimum enforcement behavior in `src/agentsh/README.md`

**Checkpoint**: User Story 1 is independently functional and testable as the MVP.

---

## Phase 4: User Story 2 - Customize project policy safely (Priority: P2)

**Goal**: A project can replace the default project policy with an overlay while the security floor remains non-overridable.

**Independent Test**: Add an overlay that changes network behavior, restart the container, confirm overlay source logging and changed behavior, then verify writes to protected policy/config/binary/shim/overlay paths are denied under a permissive overlay.

### Tests for User Story 2

- [X] T033 [P] [US2] Add custom overlay scenario assertions for overlay source logging and example.com allow behavior in `test/agentsh/custom-overlay.sh`
- [X] T034 [P] [US2] Add self-protection scenario assertions for protected writes to overlay path, `/etc/agentsh/**`, `/run/agentsh/**`, `/usr/local/share/agentsh/**`, `/usr/local/bin/agentsh`, and `/usr/local/bin/agentsh-shell-shim` in `test/agentsh/self-protection.sh`
- [X] T035 [P] [US2] Add malformed overlay startup failure assertions in `test/agentsh/malformed-overlay.sh`
- [X] T036 [P] [US2] Add missing floor startup failure assertions in `test/agentsh/missing-floor.sh`

### Implementation for User Story 2

- [X] T037 [US2] Implement workspace root and `POLICYOVERLAYPATH` resolution under the workspace root in `src/agentsh/scripts/start-server.sh`
- [X] T038 [US2] Implement overlay-vs-default user policy selection with `source=overlay:<path>` and `source=default` log output in `src/agentsh/scripts/start-server.sh`
- [X] T039 [US2] Enforce fail-loud behavior for invalid overlay, missing floor, invalid floor, and merge failure in `src/agentsh/scripts/start-server.sh`
- [X] T040 [US2] Ensure `src/agentsh/scripts/merge-policy.py` preserves user scalar keys while prepending floor list sections
- [X] T041 [US2] Document overlay replacement semantics, security floor invariants, and four customization recipes in `src/agentsh/README.md`
- [X] T042 [US2] Document policy sections, self-protection contract, and threat-model boundary in `docs/policy-reference.md`

**Checkpoint**: User Story 2 is independently functional and preserves self-protection under custom policy overlays.

---

## Phase 5: User Story 3 - Release and consume the feature publicly (Priority: P3)

**Goal**: Maintainers can validate, document, and publish the feature as a versioned public OCI artifact.

**Independent Test**: Run feature validation, shellcheck, docs validation, and release workflow checks; verify the expected GHCR namespace, version tag, latest tag, and generated docs are aligned.

### Tests for User Story 3

- [X] T043 [P] [US3] Add agentsh to generated/default feature matrix for Ubuntu and Debian in `.github/workflows/test.yaml`
- [X] T044 [P] [US3] Add Alpine agentsh scenario coverage in `.github/workflows/test.yaml`
- [X] T045 [P] [US3] Add amd64 and arm64 release validation matrix entries or documented emulation strategy in `.github/workflows/test.yaml`
- [X] T046 [P] [US3] Add shellcheck validation for `src/agentsh/install.sh` and `src/agentsh/scripts/start-server.sh` in `.github/workflows/test.yaml`
- [X] T047 [P] [US3] Add metadata/docs consistency validation for `src/agentsh/devcontainer-feature.json`, `src/agentsh/README.md`, and `README.md` in `.github/workflows/validate.yml`

### Implementation for User Story 3

- [X] T048 [US3] Update `.github/workflows/release.yaml` to publish `ghcr.io/get2knowio/devcontainer-features/agentsh:<version>` and `:latest` after validation
- [X] T049 [US3] Add generated-docs or docs-check behavior for feature README synchronization in `.github/workflows/release.yaml`
- [X] T050 [US3] Document GHCR public visibility, release tag expectations, and version bump policy in `src/agentsh/README.md`
- [X] T051 [US3] Add `agentsh` to `examples/full-stack.devcontainer.json` or document why it remains opt-in in `examples/agentsh.devcontainer.json`
- [X] T052 [US3] Update `CONTRIBUTING.md` with agentsh validation commands, architecture expectations, and release checks
- [X] T053 [US3] Update `.github/copilot-instructions.md` with agentsh-specific policy/shim/security-floor conventions

**Checkpoint**: User Story 3 is independently verifiable for release readiness.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final alignment, local validation, and cleanup across all stories.

- [X] T054 [P] Run `shellcheck src/agentsh/install.sh src/agentsh/scripts/start-server.sh` and fix findings in `src/agentsh/install.sh` or `src/agentsh/scripts/start-server.sh` (clean; intentional SC2016 placeholders suppressed with documented directives)
- [X] T055 [P] Run `python3 src/agentsh/scripts/merge-policy.py src/agentsh/policies/security-floor.yaml src/agentsh/policies/example.yaml` and fix merge/validation issues in `src/agentsh/scripts/merge-policy.py`
- [ ] T056 Run `devcontainer features test --features agentsh --base-image mcr.microsoft.com/devcontainers/base:ubuntu .` and fix failures in `src/agentsh/` or `test/agentsh/`
  - NOT APPLICABLE / superseded by T067. The autogenerated default test runs with default options (`installShellShims=true`), which replaces `/bin/sh`. The Dev Container test harness bootstraps every container through `/bin/sh`, so a shimmed default container cannot start. agentsh is intentionally excluded from the autogenerated CI matrix; real shim mediation is validated by T066/T067 (Docker integration) instead. Left unchecked deliberately.
- [X] T057 Run `devcontainer features test --features agentsh --skip-autogenerated .` and fix scenario failures in `src/agentsh/` or `test/agentsh/`
  - All retained shims-off scenarios pass (default, external-rest-api, no-webhook, malformed-overlay, missing-floor, ubuntu, debian, alpine). The `custom-overlay` and `self-protection` scenarios were removed from the harness: the Dev Container test harness does not expose the workspace mount to the feature entrypoint, so overlay-at-startup cannot be exercised there. That behavior is validated deterministically by `test/agentsh/integration/overlay_test.sh` (T069) and by `test/agentsh/policy_merge_test.sh`. Fixing these surfaced and fixed several pre-existing bugs: the webhook could not be disabled (`${VAR:-}` vs `${VAR-}`), the entrypoint crashed on a non-existent default overlay, the overlay path was not persisted to runtime, workspace detection trusted non-existent host-path env vars, the musl install omitted the shim binary, and the musl `--version` string is `dev`.
- [X] T058 Run `devcontainer features test --global-scenarios-only .` if `examples/full-stack.devcontainer.json` or global scenarios changed
- [X] T059 Verify all public references to the feature URI use `ghcr.io/get2knowio/devcontainer-features/agentsh` in `README.md`, `src/agentsh/README.md`, `examples/agentsh.devcontainer.json`, and `specs/001-agentsh-feature/quickstart.md`
- [X] T060 Re-check the latest stable `canyonroad/agentsh` release and update the default `version` option in `src/agentsh/devcontainer-feature.json` only if a newer non-prerelease is available
- [X] T061 Review `specs/001-agentsh-feature/contracts/feature-contract.md`, `specs/001-agentsh-feature/contracts/policy-contract.md`, and `specs/001-agentsh-feature/contracts/test-contract.md` against implemented files for drift

---

## Phase 7: Shell-Shim Validation Strategy & REST Auth Hardening

**Purpose**: Resolve the Dev Container harness incompatibility with the shimmed
production default, and validate external REST API auth against real agentsh
`0.20.2` behavior. Added after Phase 6 when T056/T057 surfaced the harness blocker.

- [X] T062 Add `installShellShims` option (default `true`) in `src/agentsh/devcontainer-feature.json` and gate shim installation in `src/agentsh/install.sh`; when `false`, install agentsh, policy assets, config, and the shim binary but leave `/bin/sh`/`/bin/bash` unmodified
- [X] T063 Fix `src/agentsh/install.sh` `write_api_keys_file` to emit a root-level YAML list of `{name, key}` entries (the `auth.keyFileEntry` shape agentsh requires), not an `api_keys:` map
- [X] T064 Start the agentsh server from the authoritative `/etc/agentsh/config.yaml` in `src/agentsh/scripts/start-server.sh`, and add `policies.dir`/`policies.default` for the merged runtime policy plus `security.minimum_mode: landlock` in `src/agentsh/install.sh` so auth, external bind, and the merged policy actually take effect
- [X] T065 Set `installShellShims=false` on all scenarios in `test/agentsh/scenarios.json` and move shim-mediation assertions out of `test/agentsh/test.sh` so the harness can boot
- [X] T066 Add Docker-based integration tests under `test/agentsh/integration/` (`Dockerfile`, `shim_integration_test.sh`, `rest_auth_test.sh`) that validate real shim mediation via `/bin/sh.real` and REST API key auth via `/api/v1/approvals`
- [X] T067 Add `agentsh-shim-integration` and `agentsh-rest-auth` Docker jobs in `.github/workflows/test.yaml`, drop agentsh from the autogenerated matrix, and document why agentsh needs a special CI path
- [X] T068 Update `src/agentsh/README.md`, `docs/policy-reference.md`, `CONTRIBUTING.md`, and `specs/001-agentsh-feature/contracts/feature-contract.md` for `installShellShims`, config.yaml authority, and the corrected api_keys shape
- [X] T069 Add `test/agentsh/integration/overlay_test.sh` (deterministic overlay selection + self-protection floor validation) and wire it into the `agentsh-shim-integration` CI job; remove the harness-incompatible `custom-overlay`/`self-protection` scenarios
- [X] T070 Fix runtime overlay persistence (`/etc/agentsh/feature.env`), robust workspace detection, graceful non-existent-overlay fallback, musl shim-binary install, and tolerant musl version check in `src/agentsh/install-main.sh` and `src/agentsh/scripts/start-server.sh`
- [X] T071 Remove the non-functional `approvalWebhookUrl` and `instanceId` options and the dead `/etc/agentsh/server.yaml` (agentsh 0.20.2 has no approval-push webhook and reads only `/etc/agentsh/config.yaml`). Consolidate to a single authoritative `config.yaml` with `approvals.enabled: true`; approvals are served over the REST API and resolved by a notifier sidecar. Replace the `no-webhook` scenario with `approval-timeout`; update all code, tests, docs, and contracts

**Checkpoint**: Shimmed production default is preserved; install/config/policy is
validated via shims-off scenarios; real shim mediation and REST auth are validated
via Docker integration outside the harness.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup; blocks all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational; delivers MVP install/default enforcement.
- **User Story 2 (Phase 4)**: Depends on Foundational and can use US1 runtime path; preserves independent overlay validation.
- **User Story 3 (Phase 5)**: Depends on Setup and test paths; release should wait for US1 and US2 behavior.
- **Polish (Phase 6)**: Depends on all desired user stories.

### User Story Dependencies

- **US1**: Required MVP. Must complete before release readiness can be claimed.
- **US2**: Depends on shared policy merge assets and runtime start behavior; can be developed after foundational tasks and alongside late US1 installer work if file conflicts are coordinated.
- **US3**: Can start workflow/docs scaffolding after setup, but final release validation depends on US1 and US2 tests passing.

### Within Each User Story

- Write tests before implementation tasks in the same phase.
- Implement policy assets and merge validation before runtime overlay behavior.
- Implement installer download, shim, and server config before default scenario validation.
- Complete docs and metadata updates before release workflow validation.

---

## Parallel Opportunities

- Setup placeholders T002-T008 can run in parallel after T001.
- Foundational fixture/docs tasks T014-T016 can run in parallel after policy files T009-T010 are started.
- US1 test tasks T017-T021 can run in parallel.
- US2 test tasks T033-T036 can run in parallel.
- US3 workflow validation tasks T043-T047 can run in parallel.
- Polish checks T054-T055 can run in parallel before full devcontainer feature tests.

## Parallel Example: User Story 1

```bash
# Tests can be drafted together:
Task: "T017 Add default install assertions in test/agentsh/test.sh"
Task: "T018 Add shell shim assertions in test/agentsh/test.sh"
Task: "T019 Add enforcement assertion in test/agentsh/default.sh"
Task: "T020 Add default policy denial assertions in test/agentsh/default.sh"
Task: "T021 Add mock approval webhook assertion in test/agentsh/default.sh"
```

## Parallel Example: User Story 2

```bash
# Scenario tests use separate files and can be drafted together:
Task: "T033 Add custom overlay scenario assertions in test/agentsh/custom-overlay.sh"
Task: "T034 Add self-protection scenario assertions in test/agentsh/self-protection.sh"
Task: "T035 Add malformed overlay startup failure assertions in test/agentsh/malformed-overlay.sh"
Task: "T036 Add missing floor startup failure assertions in test/agentsh/missing-floor.sh"
```

## Parallel Example: User Story 3

```bash
# Workflow updates need final reconciliation but can be drafted independently:
Task: "T043 Add agentsh to generated/default feature matrix in .github/workflows/test.yaml"
Task: "T044 Add Alpine agentsh scenario coverage in .github/workflows/test.yaml"
Task: "T046 Add shellcheck validation in .github/workflows/test.yaml"
Task: "T047 Add metadata/docs consistency validation in .github/workflows/validate.yml"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 setup and Phase 2 foundational policy/merge assets.
2. Complete US1 tests and implementation.
3. Validate default install behavior with the Ubuntu feature test command.
4. Stop and review before overlay/release work.

### Incremental Delivery

1. Deliver US1 default install and enforcement.
2. Add US2 overlay customization and self-protection validation.
3. Add US3 workflow, docs, release, and architecture validation.
4. Run polish checks and contract drift review.

### Release Readiness

Release is not ready until US1, US2, US3, and all polish validation tasks pass or have a documented blocker.

## Notes

- `[P]` tasks touch separate files or can be drafted independently.
- Story labels map to `spec.md` user stories.
- Every user story has explicit test tasks because the constitution requires behavior-changing feature tests.
- The first release default is planned as agentsh `0.20.2`, but T060 requires a final stable release check before implementation release.
