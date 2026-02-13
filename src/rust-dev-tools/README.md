# Rust Development Tools (rust-dev-tools)

Installs Rust development tools: bacon (build watcher), cargo-edit, and cargo-audit.

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `install` | Comma-separated list of tools to install (e.g. `"bacon"`). When set, only the listed tools are installed. When empty, all tools are installed. | string | `""` |
| `omit` | Comma-separated list of tools to exclude (e.g. `"cargoAudit"`). When set, the listed tools are skipped. Applied after `install` filtering. | string | `""` |

## Usage

Add this feature to your `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/rust-dev-tools:2": {}
  }
}
```

### Install only bacon

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/rust-dev-tools:2": {
      "install": "bacon"
    }
  }
}
```

**Requires:** Rust (installs after `ghcr.io/devcontainers/features/rust`)
