#!/bin/bash
set -e

echo "Installing Python development tools..."

# uv - fast Python package manager
if [ "${UV}" = "true" ]; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | env INSTALLER_NO_MODIFY_PATH=1 sh
    # Make available system-wide
    ln -sf /root/.local/bin/uv /usr/local/bin/uv
    ln -sf /root/.local/bin/uvx /usr/local/bin/uvx
fi

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

# ruff - fast Python linter and formatter
if [ "${RUFF}" = "true" ]; then
    echo "Installing ruff..."
    pip install ruff
fi

# mypy - static type checker
if [ "${MYPY}" = "true" ]; then
    echo "Installing mypy..."
    pip install mypy
fi

echo "Python development tools installation complete."
