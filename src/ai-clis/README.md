# AI CLI Tools (ai-clis)

Installs AI coding assistant CLIs and agentic development tools: Claude Code, Gemini CLI, OpenAI Codex, GitHub Copilot, OpenCode, CodeRabbit, Beads, and Specify CLI.

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `installMode` | `"all"` installs every CLI unless explicitly disabled; `"selected"` installs only CLIs explicitly set to true | string | `all` |
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

With the default `installMode: "all"`, disable specific CLIs:

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

Set `installMode` to `"selected"` and enable just what you need — new CLIs added in future releases won't be installed unless you opt in:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/ai-clis:1": {
      "installMode": "selected",
      "claudeCode": true,
      "geminiCli": true
    }
  }
}
```

**Requires:** Node.js (installs after `ghcr.io/devcontainers/features/node`)
