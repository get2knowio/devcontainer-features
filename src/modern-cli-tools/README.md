# Modern CLI Tools (modern-cli-tools)

Installs modern CLI replacements and TUI tools: bat, ripgrep, fd, fzf, eza, zoxide, neovim, tmux, lazygit, ast-grep, jujutsu, and optionally zellij.

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `bat` | Install bat (cat replacement with syntax highlighting) | boolean | `true` |
| `ripgrep` | Install ripgrep (fast grep replacement) | boolean | `true` |
| `fd` | Install fd (fast find replacement) | boolean | `true` |
| `fzf` | Install fzf (fuzzy finder) | boolean | `true` |
| `eza` | Install eza (modern ls replacement) | boolean | `true` |
| `zoxide` | Install zoxide (smart cd replacement) | boolean | `true` |
| `neovim` | Install neovim | boolean | `true` |
| `tmux` | Install tmux (terminal multiplexer) | boolean | `true` |
| `lazygit` | Install lazygit (Git TUI) | boolean | `true` |
| `astGrep` | Install ast-grep (structural search tool) | boolean | `true` |
| `jujutsu` | Install jujutsu (jj, next-gen Git-compatible VCS) | boolean | `true` |
| `zellij` | Install zellij (terminal workspace) | boolean | `false` |
| `jujutsuVersion` | Version of jujutsu to install | string | `0.38.0` |
| `ezaVersion` | Version of eza to install | string | `latest` |
| `lazygitVersion` | Version of lazygit to install | string | `0.59.0` |
| `astGrepVersion` | Version of ast-grep to install | string | `0.40.5` |
| `zellijVersion` | Version of zellij to install | string | `0.43.1` |

## Usage

Add this feature to your `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/modern-cli-tools:1": {}
  }
}
```

### Enable zellij and pin lazygit version

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/modern-cli-tools:1": {
      "zellij": true,
      "lazygitVersion": "0.58.0"
    }
  }
}
```
