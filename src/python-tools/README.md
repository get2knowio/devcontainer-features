# Python Development Tools (python-tools)

Installs Python development tools: uv, Poetry, ruff, and mypy.

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `install` | Comma-separated list of tools to install (e.g. `"uv,ruff"`). When set, only the listed tools are installed. When empty, all tools are installed. | string | `""` |
| `omit` | Comma-separated list of tools to exclude (e.g. `"mypy"`). When set, the listed tools are skipped. Applied after `install` filtering. | string | `""` |
| `poetryVersion` | Version of Poetry to install | string | `latest` |
| `inProjectVenvs` | Configure Poetry to create virtualenvs in project directory | boolean | `true` |

## Usage

Add this feature to your `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/python-tools:2": {}
  }
}
```

### Install only uv and ruff

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/python-tools:2": {
      "install": "uv,ruff"
    }
  }
}
```

**Requires:** Python (installs after `ghcr.io/devcontainers/features/python`)
