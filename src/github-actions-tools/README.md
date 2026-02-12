
# GitHub Actions Tools (github-actions-tools)

Installs tools for local GitHub Actions development: act (local runner) and actionlint (workflow linter).

## Example Usage

```json
"features": {
    "ghcr.io/get2knowio/devcontainer-features/github-actions-tools:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| act | Install act (run GitHub Actions locally) | boolean | true |
| actionlint | Install actionlint (GitHub Actions workflow linter) | boolean | true |
| actVersion | Version of act to install | string | 0.2.84 |
| actionlintVersion | Version of actionlint to install | string | 1.7.10 |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/get2knowio/devcontainer-features/blob/main/src/github-actions-tools/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
