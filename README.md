# get2know.io DevContainer Feature Collection

A collection of **Dev Container Features** published as OCI artifacts to `ghcr.io/get2knowio/devcontainer-features`. Pick individual feature bundles or compose them all for a full-stack environment.

## Features

| Feature | Description |
|---------|-------------|
| [`ai-clis`](src/ai-clis/) | AI coding assistant CLIs (Claude Code, Gemini, Codex, Copilot, OpenCode, CodeRabbit, Beads, Specify CLI) |
| [`modern-cli-tools`](src/modern-cli-tools/) | Modern CLI replacements (bat, ripgrep, fd, fzf, eza, zoxide, neovim, tmux, lazygit, ast-grep, jujutsu) |
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
    "ghcr.io/get2knowio/devcontainer-features/modern-cli-tools:1": {},
    "ghcr.io/get2knowio/devcontainer-features/github-actions-tools:1": {}
  }
}
```

## Feature Options

### ai-clis

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `claudeCode` | boolean | `true` | Install Claude Code CLI |
| `geminiCli` | boolean | `true` | Install Google Gemini CLI |
| `codex` | boolean | `true` | Install OpenAI Codex CLI |
| `copilot` | boolean | `true` | Install GitHub Copilot CLI |
| `openCode` | boolean | `true` | Install OpenCode AI CLI |
| `codeRabbit` | boolean | `true` | Install CodeRabbit CLI |
| `beads` | boolean | `true` | Install Beads (coding agent memory system) |
| `specifyCli` | boolean | `true` | Install Specify CLI (spec-driven development toolkit) |

### modern-cli-tools

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `bat` | boolean | `true` | bat (cat replacement with syntax highlighting) |
| `ripgrep` | boolean | `true` | ripgrep (fast grep replacement) |
| `fd` | boolean | `true` | fd (fast find replacement) |
| `fzf` | boolean | `true` | fzf (fuzzy finder) |
| `eza` | boolean | `true` | eza (modern ls replacement) |
| `zoxide` | boolean | `true` | zoxide (smart cd replacement) |
| `neovim` | boolean | `true` | neovim |
| `tmux` | boolean | `true` | tmux (terminal multiplexer) |
| `lazygit` | boolean | `true` | lazygit (Git TUI) |
| `astGrep` | boolean | `true` | ast-grep (structural search tool) |
| `jujutsu` | boolean | `true` | jujutsu (jj, next-gen Git-compatible VCS) |
| `zellij` | boolean | `false` | zellij (terminal workspace) |
| `lazygitVersion` | string | `0.59.0` | Version of lazygit |
| `astGrepVersion` | string | `0.40.5` | Version of ast-grep |
| `jujutsuVersion` | string | `0.38.0` | Version of jujutsu |
| `zellijVersion` | string | `0.43.1` | Version of zellij |

### node-dev-tools

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `typescript` | boolean | `true` | TypeScript, ts-node, tsx, @types/node |
| `bundlers` | boolean | `true` | vite, esbuild |
| `linters` | boolean | `true` | prettier, eslint, biome |
| `watchers` | boolean | `true` | nodemon, tsc-watch, concurrently |
| `bun` | boolean | `true` | Bun JavaScript runtime |

### rust-dev-tools

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `bacon` | boolean | `true` | bacon (build watcher, replaces cargo-watch) |
| `cargoEdit` | boolean | `true` | cargo-edit (cargo add/rm/upgrade) |
| `cargoAudit` | boolean | `true` | cargo-audit (security vulnerability checker) |

### github-actions-tools

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `act` | boolean | `true` | act (run GitHub Actions locally) |
| `actionlint` | boolean | `true` | actionlint (workflow linter) |
| `actVersion` | string | `0.2.84` | Version of act |
| `actionlintVersion` | string | `1.7.10` | Version of actionlint |

### python-tools

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `uv` | boolean | `true` | uv (fast Python package manager) |
| `poetry` | boolean | `true` | Poetry package manager |
| `ruff` | boolean | `true` | ruff (fast Python linter and formatter) |
| `mypy` | boolean | `true` | mypy (static type checker) |
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
