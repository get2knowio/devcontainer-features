# GitHub Actions Tools (github-actions-tools)

Installs tools for local GitHub Actions development: act (local runner) and actionlint (workflow linter).

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| `act` | Install act (run GitHub Actions locally) | boolean | `true` |
| `actionlint` | Install actionlint (GitHub Actions workflow linter) | boolean | `true` |
| `actVersion` | Version of act to install | string | `0.2.84` |
| `actionlintVersion` | Version of actionlint to install | string | `1.7.10` |

## Usage

Add this feature to your `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/github-actions-tools:1": {}
  }
}
```

### Pin specific versions

```jsonc
{
  "features": {
    "ghcr.io/get2knowio/devcontainer-features/github-actions-tools:1": {
      "actVersion": "0.2.80",
      "actionlintVersion": "1.7.5"
    }
  }
}
```
