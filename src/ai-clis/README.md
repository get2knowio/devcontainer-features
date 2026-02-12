# AI CLI Tools (ai-clis)

Installs AI coding assistant CLIs and agentic development tools: Claude Code, Gemini CLI, OpenAI Codex, GitHub Copilot, OpenCode, CodeRabbit, Beads, and Specify CLI.

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `install` | Comma-separated list of CLIs to install (e.g. `"claudeCode,geminiCli"`). When set, only the listed CLIs are installed. When empty, all CLIs are installed. | string | `""` |
| `claudeCode` | Install Claude Code CLI | boolean | `true` |
| `geminiCli` | Install Google Gemini CLI | boolean | `true` |
| `codex` | Install OpenAI Codex CLI | boolean | `true` |
| `copilot` | Install GitHub Copilot CLI | boolean | `true` |
| `openCode` | Install OpenCode AI CLI | boolean | `true` |
| `codeRabbit` | Install CodeRabbit CLI | boolean | `true` |
| `beads` | Install Beads (coding agent memory system) | boolean | `true` |
| `specifyCli` | Install Specify CLI (spec-driven development toolkit) | boolean | `true` |

> These tools can be large — disable any you don't need to speed up container builds.

## Usage

Add this feature to your `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/ai-clis:1": {}
  }
}
```

### Install everything except a few

Disable specific CLIs with individual boolean options:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/ai-clis:1": {
      "codex": false,
      "copilot": false
    }
  }
}
```

### Install only the CLIs you want

Use `install` to list exactly the CLIs you need — new CLIs added in future releases won't be installed unless you opt in:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/ai-clis:1": {
      "install": "claudeCode,geminiCli"
    }
  }
}
```

**Requires:** Node.js (installs after `ghcr.io/devcontainers/features/node`)
