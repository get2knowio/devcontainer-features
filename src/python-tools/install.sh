#!/bin/bash
set -e

echo "Installing Python development tools..."

# Poetry
if [ "${POETRY}" = "true" ]; then
    echo "Installing Poetry ${POETRYVERSION}..."
    export POETRY_HOME=/opt/poetry
    curl -sSL https://install.python-poetry.org | python3 - --version "${POETRYVERSION}"
    ln -sf "${POETRY_HOME}/bin/poetry" /usr/local/bin/poetry

    # Configure in-project virtualenvs
    if [ "${INPROJECTVENVS}" = "true" ]; then
        su - "$_REMOTE_USER" -c 'poetry config virtualenvs.in-project true --global' || true
    fi
fi

# Specify CLI via uv
if [ "${SPECIFYCLI}" = "true" ]; then
    echo "Installing Specify CLI (spec-kit) via uv..."
    # Ensure uv is available
    if command -v uv >/dev/null 2>&1; then
        UV_BIN="$(command -v uv)"
    else
        echo "uv not found; installing via Astral script..."
        su - "$_REMOTE_USER" -c 'curl -Ls https://astral.sh/uv/install.sh | sh'
        UV_BIN="$_REMOTE_USER_HOME/.local/bin/uv"
    fi
    # Ensure ~/.local/bin on PATH
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$_REMOTE_USER_HOME/.zshrc"
    su - "$_REMOTE_USER" -c "\"$UV_BIN\" tool install specify-cli --from git+https://github.com/github/spec-kit.git" || echo "Warning: Specify CLI installation failed"
fi

echo "Python development tools installation complete."
