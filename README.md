# get2know.io DevContainer Feature Collection

A collection of **Dev Container Features** published as OCI artifacts to `ghcr.io/get2knowio/devcontainer-features`. Pick individual feature bundles or compose them all for a full-stack environment.

## Features

| Feature | Description |
|---------|-------------|
| [`ai-clis`](src/ai-clis/) | AI coding assistant CLIs (Claude Code, Gemini, Codex, Copilot, OpenCode, CodeRabbit, Beads + Dolt, Specify CLI, QMD, Claude Agent ACP) |
| [`modern-cli-tools`](src/modern-cli-tools/) | Modern CLI replacements (bat, ripgrep, fd, fzf, eza, zoxide, neovim, tmux, lazygit, ast-grep, jujutsu, zellij, starship) |
| [`node-dev-tools`](src/node-dev-tools/) | Node.js toolchain (TypeScript, bundlers, linters, watchers, Bun) |
| [`rust-dev-tools`](src/rust-dev-tools/) | Rust development tools (bacon, cargo-edit, cargo-audit) |
| [`github-actions-tools`](src/github-actions-tools/) | GitHub Actions local dev tools (act, actionlint) |
| [`python-tools`](src/python-tools/) | Python development tools (uv, Poetry, ruff, mypy) |
| [`agentsh`](src/agentsh/) | agentsh execution-layer security with shell shims, policy floor, overlays, and REST API approvals |

---

## Quick Start

Add any feature to your `.devcontainer/devcontainer.json`:

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/modern-cli-tools:2": {},
    "ghcr.io/get2knowio/devcontainer-features/github-actions-tools:2": {},
    "ghcr.io/get2knowio/devcontainer-features/agentsh:0.1.0": {}
  }
}
```

## Feature Options

Every feature supports two string options for tool selection:

| Option | Description |
|--------|-------------|
| `install` | Comma-separated whitelist — only install the listed tools. When empty (default), all tools are installed. |
| `omit` | Comma-separated blacklist — exclude the listed tools. Applied after `install` filtering. |

### ai-clis

Tools: `claudeCode`, `geminiCli`, `codex`, `copilot`, `openCode`, `codeRabbit`, `beads`, `specifyCli`, `qmd`, `claudeAgentAcp`

### modern-cli-tools

Tools: `bat`, `ripgrep`, `fd`, `fzf`, `eza`, `zoxide`, `neovim`, `tmux`, `lazygit`, `astGrep`, `jujutsu`, `zellij`, `starship`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `lazygitVersion` | string | `latest` | Version of lazygit, or 'latest' |
| `astGrepVersion` | string | `latest` | Version of ast-grep, or 'latest' |
| `jujutsuVersion` | string | `latest` | Version of jujutsu, or 'latest' |
| `ezaVersion` | string | `latest` | Version of eza, or 'latest' |
| `zellijVersion` | string | `latest` | Version of zellij, or 'latest' |
| `starshipVersion` | string | `latest` | Version of starship, or 'latest' |

### node-dev-tools

Tool groups: `typescript`, `bundlers`, `linters`, `watchers`, `bun`

### rust-dev-tools

Tools: `bacon`, `cargoEdit`, `cargoAudit`

### github-actions-tools

Tools: `act`, `actionlint`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `actVersion` | string | `latest` | Version of act, or 'latest' |
| `actionlintVersion` | string | `latest` | Version of actionlint, or 'latest' |

### python-tools

Tools: `uv`, `poetry`, `ruff`, `mypy`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `poetryVersion` | string | `latest` | Version of Poetry, or 'latest' |
| `inProjectVenvs` | boolean | `true` | Configure Poetry for in-project virtualenvs |

### agentsh

Canonical URI: `ghcr.io/get2knowio/devcontainer-features/agentsh`

`agentsh` installs one cohesive security runtime and does not support the collection-wide `install`/`omit` tool selection options.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `0.20.2` | Pinned upstream agentsh release. |
| `approvalTimeoutSeconds` | number | `300` | Approval timeout before fail-secure deny. |
| `shimForceNonTty` | boolean | `true` | Force non-TTY shell shim mediation. |
| `installShellShims` | boolean | `true` | Replace `/bin/sh` and `/bin/bash` with the agentsh shim (secure default). |
| `installDevDependencies` | boolean | `true` | Install required OS packages. |
| `policyOverlayPath` | string | `.devcontainer/agentsh-policy.yaml` | Workspace-relative overlay policy. |
| `externalRestApi` | boolean | `false` | Bind the REST API for an external notifier sidecar. Requires `restApiKey`. |
| `restPort` | number | `18080` | REST API port. |
| `restApiKey` | string | `""` | API key required for external REST clients. |

---

## Full-Stack Example

For a complete development environment, see [`examples/full-stack.devcontainer.json`](examples/full-stack.devcontainer.json). It composes all 6 general-purpose custom features with standard Dev Container features for Python, Node.js, Rust, Docker, and more. `agentsh` remains opt-in because it changes shell mediation, startup policy, and runtime security posture; see [`examples/agentsh.devcontainer.json`](examples/agentsh.devcontainer.json).

## Shell Aliases

Features that install shell aliases append them to `$_REMOTE_USER_HOME/.zshrc`:

**modern-cli-tools**: `ls`/`ll`/`la` (eza), zoxide init
**node-dev-tools**: `tsc`, `tsx`, `tsw`, `dev`, `build`, `test`, `lint`, `format` + npm completion
**rust-dev-tools**: `cr`, `cb`, `ct`, `cc`, `cf`, `cl`, `cw` (bacon), `cn`, `ca`, `cup` + rustup/cargo completion
**agentsh**: `/bin/bash` and `/bin/sh` are mediated through `/usr/local/bin/agentsh-shell-shim`

## Automated Dependency Updates

Renovate tracks GitHub Actions versions in CI workflows. Tool versions resolve to latest at container build time; pin specific versions via feature options if needed.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for development workflow, testing, and how to add features.

## License

See [LICENSE](LICENSE).
