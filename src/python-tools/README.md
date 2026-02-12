
# Python Development Tools (python-tools)

Installs Python development tools: uv, Poetry, ruff, and mypy.

## Example Usage

```json
"features": {
    "ghcr.io/get2knowio/devcontainer-features/python-tools:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| uv | Install uv (fast Python package manager) | boolean | true |
| poetry | Install Poetry package manager | boolean | true |
| ruff | Install ruff (fast Python linter and formatter) | boolean | true |
| mypy | Install mypy (static type checker) | boolean | true |
| poetryVersion | Version of Poetry to install | string | 2.3.2 |
| inProjectVenvs | Configure Poetry to create virtualenvs in project directory | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/get2knowio/devcontainer-features/blob/main/src/python-tools/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
