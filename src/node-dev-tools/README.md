
# Node.js Development Tools (node-dev-tools)

Installs TypeScript toolchain, bundlers, linters, file watchers, and Bun runtime for Node.js development.

## Example Usage

```json
"features": {
    "ghcr.io/get2knowio/devcontainer-features/node-dev-tools:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| typescript | Install TypeScript, ts-node, tsx, and @types/node | boolean | true |
| bundlers | Install vite and esbuild | boolean | true |
| linters | Install prettier, eslint, and biome | boolean | true |
| watchers | Install nodemon, tsc-watch, and concurrently | boolean | true |
| bun | Install Bun JavaScript runtime | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/get2knowio/devcontainer-features/blob/main/src/node-dev-tools/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
