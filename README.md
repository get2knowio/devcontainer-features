# get2know.io DevContainer Feature Collection

A collection of **Dev Container Features** published as OCI artifacts to `ghcr.io/get2knowio/devcontainer-features`. Pick individual feature bundles or compose them all for a full-stack environment.

## Features

| Feature | Description |
|---------|-------------|
| [`ai-clis`](src/ai-clis/) | AI coding assistant CLIs (Claude Code, Gemini, Codex, Copilot, OpenCode, CodeRabbit, Beads, Specify CLI) |
| [`modern-cli-tools`](src/modern-cli-tools/) | Modern CLI replacements (bat, ripgrep, fd, fzf, eza, zoxide, neovim, tmux, lazygit, ast-grep, jujutsu, zellij) |
| [`node-dev-tools`](src/node-dev-tools/) | Node.js toolchain (TypeScript, bundlers, linters, watchers, Bun) |
| [`rust-dev-tools`](src/rust-dev-tools/) | Rust development tools (bacon, cargo-edit, cargo-audit) |
| [`github-actions-tools`](src/github-actions-tools/) | GitHub Actions local dev tools (act, actionlint) |
| [`python-tools`](src/python-tools/) | Python development tools (uv, Poetry, ruff, mypy) |

---

## Quick Start

Add any feature to your `.devcontainer/devcontainer.json`:

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/modern-cli-tools:2": {},
    "ghcr.io/get2knowio/devcontainer-features/github-actions-tools:2": {}
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

Tools: `claudeCode`, `geminiCli`, `codex`, `copilot`, `openCode`, `codeRabbit`, `beads`, `specifyCli`

### modern-cli-tools

Tools: `bat`, `ripgrep`, `fd`, `fzf`, `eza`, `zoxide`, `neovim`, `tmux`, `lazygit`, `astGrep`, `jujutsu`, `zellij`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `lazygitVersion` | string | `0.59.0` | Version of lazygit |
| `astGrepVersion` | string | `0.40.5` | Version of ast-grep |
| `jujutsuVersion` | string | `0.38.0` | Version of jujutsu |
| `ezaVersion` | string | `latest` | Version of eza |
| `zellijVersion` | string | `0.43.1` | Version of zellij |

### node-dev-tools

Tool groups: `typescript`, `bundlers`, `linters`, `watchers`, `bun`

### rust-dev-tools

Tools: `bacon`, `cargoEdit`, `cargoAudit`

### github-actions-tools

Tools: `act`, `actionlint`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `actVersion` | string | `0.2.84` | Version of act |
| `actionlintVersion` | string | `1.7.10` | Version of actionlint |

### python-tools

Tools: `uv`, `poetry`, `ruff`, `mypy`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `poetryVersion` | string | `2.3.2` | Version of Poetry |
| `inProjectVenvs` | boolean | `true` | Configure Poetry for in-project virtualenvs |

---

## Full-Stack Example

For a complete development environment, see [`examples/full-stack.devcontainer.json`](examples/full-stack.devcontainer.json). It composes all 6 custom features with standard Dev Container features for Python, Node.js, Rust, Docker, and more.

## Shell Aliases

Features that install shell aliases append them to `$_REMOTE_USER_HOME/.zshrc`:

**modern-cli-tools**: `ls`/`ll`/`la` (eza), zoxide init
**node-dev-tools**: `tsc`, `tsx`, `tsw`, `dev`, `build`, `test`, `lint`, `format` + npm completion
**rust-dev-tools**: `cr`, `cb`, `ct`, `cc`, `cf`, `cl`, `cw` (bacon), `cn`, `ca`, `cup` + rustup/cargo completion

## Automated Dependency Updates

[Renovate](https://docs.renovatebot.com) tracks version defaults in `devcontainer-feature.json` files via custom regex managers. Updates run weekly before 06:00 UTC on Mondays. Patch updates automerge; major/minor require review.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for development workflow, testing, and how to add features.

## License

See [LICENSE](LICENSE).
