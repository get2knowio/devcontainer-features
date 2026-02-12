
# Rust Development Tools (rust-dev-tools)

Installs Rust development tools: bacon (build watcher), cargo-edit, and cargo-audit.

## Example Usage

```json
"features": {
    "ghcr.io/get2knowio/devcontainer-features/rust-dev-tools:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| bacon | Install bacon (cargo build watcher, replaces cargo-watch) | boolean | true |
| cargoEdit | Install cargo-edit (cargo add/rm/upgrade) | boolean | true |
| cargoAudit | Install cargo-audit (security vulnerability checker) | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/get2knowio/devcontainer-features/blob/main/src/rust-dev-tools/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
