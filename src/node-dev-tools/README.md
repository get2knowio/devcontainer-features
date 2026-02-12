# Node.js Development Tools (node-dev-tools)

Installs TypeScript toolchain, bundlers, linters, file watchers, and Bun runtime for Node.js development.

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `install` | Comma-separated list of tool groups to install (e.g. `"typescript,bun"`). When set, only the listed groups are installed. When empty, all groups are installed. | string | `""` |
| `typescript` | Install TypeScript, ts-node, tsx, and @types/node | boolean | `true` |
| `bundlers` | Install vite and esbuild | boolean | `true` |
| `linters` | Install prettier, eslint, and biome | boolean | `true` |
| `watchers` | Install nodemon, tsc-watch, and concurrently | boolean | `true` |
| `bun` | Install Bun JavaScript runtime | boolean | `true` |

## Usage

Add this feature to your `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/node-dev-tools:1": {}
  }
}
```

### TypeScript and Bun only

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/node-dev-tools:1": {
      "install": "typescript,bun"
    }
  }
}
```

**Requires:** Node.js (installs after `ghcr.io/devcontainers/features/node`)
