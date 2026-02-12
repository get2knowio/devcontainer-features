# Rust Development Tools (rust-dev-tools)

Installs Rust development tools: bacon (build watcher), cargo-edit, and cargo-audit.

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `bacon` | Install bacon (cargo build watcher, replaces cargo-watch) | boolean | `true` |
| `cargoEdit` | Install cargo-edit (cargo add/rm/upgrade) | boolean | `true` |
| `cargoAudit` | Install cargo-audit (security vulnerability checker) | boolean | `true` |

## Usage

Add this feature to your `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/rust-dev-tools:1": {}
  }
}
```

### Install only bacon

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/rust-dev-tools:1": {
      "cargoEdit": false,
      "cargoAudit": false
    }
  }
}
```

**Requires:** Rust (installs after `ghcr.io/devcontainers/features/rust`)
