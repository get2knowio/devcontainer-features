# Implementation Plan: Agentsh DevContainer Feature

**Branch**: `001-agentsh-feature` | **Date**: 2026-06-01 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-agentsh-feature/spec.md`

## Summary

Add a new `agentsh` Dev Container Feature under the existing multi-feature repository. The
feature publishes as `ghcr.io/get2knowio/devcontainer-features/agentsh`, installs a pinned
stable agentsh Linux release at build time, activates bash and sh shell shims, installs a
default policy plus non-overridable security floor, merges the active policy at container
start, and serves policy approval decisions asynchronously over the agentsh REST API.
Planning preserves the current repository layout while adding contracts, tests, docs, and
release validation required for a security-sensitive public feature.

## Technical Context

**Language/Version**: Bash for `install.sh` and `start-server.sh`; Python 3 with PyYAML for
policy merge/validation; JSON for feature metadata and scenario definitions; YAML for
agentsh policy/configuration and GitHub Actions.

**Primary Dependencies**: agentsh release artifacts from `canyonroad/agentsh`; Dev Container
Feature schema/CLI/action; `curl`, `jq`, `ca-certificates`, `python3`, PyYAML, and
`shellcheck` in test/release workflows.

**Storage**: File-backed container configuration and runtime state:
`/etc/agentsh/policy.yaml`, `/etc/agentsh/config.yaml` (authoritative server config),
`/etc/agentsh/feature.env`, `/usr/local/share/agentsh/security-floor.yaml`,
`/usr/local/share/agentsh/start-server.sh`, `/usr/local/share/agentsh/merge-policy.py`, and
`/run/agentsh/policy.yaml`.

**Testing**: `devcontainer features test` for generated/default/scenario tests; shellcheck
for shell scripts; policy merge unit checks via the scenario harness; release validation
matrix covering Ubuntu, Debian, Alpine, amd64, and arm64 where CI runner support permits.

**Target Platform**: Linux devcontainers consumed by spec-compliant tools; Debian/Ubuntu
glibc and Alpine/musl base images; amd64 and arm64 architectures; at least Landlock-level
agentsh enforcement required for a successful build/start.

**Project Type**: Dev Container Feature collection with one new public feature.

**Performance Goals**: Container startup policy merge completes in under 2 seconds for the
default/example policies; install-time verification adds no long-running network reachability
probe beyond release downloads and local `agentsh detect`.

**Constraints**: No host modification; no bundled agentsh binary; pinned stable agentsh
release; agentsh-native approval payloads only; no Telegram/notifier credentials; no runtime
policy switching or live reload; no disabling the security floor; no second baseline policy;
shell scripts use strict mode and remain shellcheck-clean.

**Scale/Scope**: One new feature (`src/agentsh`), three primary scenario groups
(default, custom overlay, self-protection), three Linux base-image families, two CPU
architectures for release validation, and docs/contracts for first public release `0.1.0`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Feature Contract Fidelity**: PASS. Plan identifies `src/agentsh/devcontainer-feature.json`,
  `src/agentsh/install.sh`, policy assets, scripts, tests, docs, examples, and version
  `0.1.0` as the new public contract surface. See [contracts/feature-contract.md](./contracts/feature-contract.md).
- **Selective, Idempotent Installation**: PASS. `agentsh` is exempt from `install`/`omit`
  because it installs one cohesive security product, and the plan requires idempotent
  strict-mode installers, required-step failures, clear warnings, and shim/policy rerun
  safety. See [research.md](./research.md).
- **Cross-Architecture Compatibility**: PASS. Plan covers Debian/Ubuntu and Alpine,
  glibc/musl release artifact selection, amd64 and arm64 validation, `installsAfter`,
  runtime capability metadata, and pinned release behavior. See [quickstart.md](./quickstart.md).
- **Testable Feature Changes**: PASS. Default, overlay, self-protection, base-image,
  architecture, shellcheck, and release validation paths are planned. See
  [contracts/test-contract.md](./contracts/test-contract.md).
- **Documentation, Versioning, Release Readiness**: PASS. Plan requires root README,
  feature README, policy reference, quickstart, generated docs alignment, v0.1.0 feature
  metadata, and release workflow updates before readiness.

Post-design re-check: PASS. Phase 1 artifacts preserve the gates above; no complexity
violations are introduced.

## Project Structure

### Documentation (this feature)

```text
specs/001-agentsh-feature/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── feature-contract.md
│   ├── policy-contract.md
│   └── test-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
src/
└── agentsh/
    ├── devcontainer-feature.json
    ├── install.sh            # POSIX bootstrap (ensures bash) -> install-main.sh
    ├── install-main.sh       # Bash installer implementation
    ├── README.md
    ├── scripts/
    │   ├── start-server.sh
    │   └── merge-policy.py
    └── policies/
        ├── security-floor.yaml
        └── example.yaml

test/
└── agentsh/
    ├── test.sh
    ├── scenarios.json        # shims-off scenarios the harness can boot
    ├── default.sh
    ├── policy_merge_test.sh
    └── integration/          # Docker probes outside the Dev Container harness
        ├── Dockerfile
        ├── shim_integration_test.sh
        ├── overlay_test.sh
        └── rest_auth_test.sh

docs/
└── policy-reference.md

examples/
└── agentsh.devcontainer.json

.github/workflows/
├── test.yaml
├── release.yaml
└── validate.yml
```

**Structure Decision**: Use the repository's existing multi-feature layout. The new
`agentsh` feature is isolated under `src/agentsh` and `test/agentsh`, with shared root docs,
examples, and workflows updated only where required for discovery, validation, and release.

## Complexity Tracking

No constitution violations require justification.
