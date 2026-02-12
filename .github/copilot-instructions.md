# Copilot Instructions

This document contains instructions and conventions for GitHub Copilot when working on this project.

## Project Structure

This is a **Dev Container Feature Collection** published as OCI artifacts. Each feature lives in `src/<feature>/` with two files:
- `devcontainer-feature.json` — metadata, options, dependencies
- `install.sh` — installation script

```
src/
  ai-clis/
  modern-cli-tools/
  node-dev-tools/
  rust-dev-tools/
  github-actions-tools/
  python-tools/
test/
  <feature>/           # Per-feature tests
  _global/             # Composition tests
examples/
  full-stack.devcontainer.json
```

## Feature Development Conventions

### install.sh Scripts

- Start with `#!/bin/bash` and `set -e`
- Options from `devcontainer-feature.json` are available as uppercase environment variables (e.g., `CLAUDECODE`, `LAZYGITVERSION`)
- Use `$_REMOTE_USER` and `$_REMOTE_USER_HOME` for user context
- Use `su - "$_REMOTE_USER"` for user-scoped installs
- Handle both `amd64` and `arm64` architectures via `dpkg --print-architecture`
- Append shell configuration to `$_REMOTE_USER_HOME/.zshrc`

### devcontainer-feature.json

- Use boolean options (default `true`) for individual tool toggles
- Use string options for version pinning
- Include `installsAfter` for features that depend on language runtimes

### Shell Support

- **Primary Shell**: zsh only
- All aliases and shell configuration target `~/.zshrc`
- No bash compatibility required for shell config

### Testing

- Each feature has `test/<feature>/test.sh` using `dev-container-features-test-lib`
- Use `check "description" bash -c "command"` + `reportResults` pattern
- Scenario tests in `scenarios.json` test specific option combinations
- Global tests in `test/_global/` verify features compose together

## When Making Changes

1. **Adding a tool to an existing feature**: Update `install.sh` with conditional install, add option to `devcontainer-feature.json`, add test checks
2. **Adding a new feature**: Create `src/<name>/`, add tests, update global test, update examples and docs
3. **Updating tool versions**: Change the `default` in `devcontainer-feature.json` (Renovate handles this automatically for tracked tools)
4. **CI changes**: Workflows are in `.github/workflows/` — `test.yaml` (testing), `release.yaml` (publishing), `validate.yml` (schema validation)
