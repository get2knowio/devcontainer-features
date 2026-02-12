# Python Development Tools (python-tools)

Installs Python development tools: uv, Poetry, ruff, and mypy.

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `uv` | Install uv (fast Python package manager) | boolean | `true` |
| `poetry` | Install Poetry package manager | boolean | `true` |
| `ruff` | Install ruff (fast Python linter and formatter) | boolean | `true` |
| `mypy` | Install mypy (static type checker) | boolean | `true` |
| `poetryVersion` | Version of Poetry to install | string | `2.3.2` |
| `inProjectVenvs` | Configure Poetry to create virtualenvs in project directory | boolean | `true` |

## Usage

Add this feature to your `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/python-tools:1": {}
  }
}
```

### Use only uv and ruff

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/python-tools:1": {
      "poetry": false,
      "mypy": false
    }
  }
}
```

**Requires:** Python (installs after `ghcr.io/devcontainers/features/python`)
