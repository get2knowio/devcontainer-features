#!/bin/bash
set -e

echo "Installing Python development tools..."

# If 'install' is set, only install the listed tools (comma-separated).
# Otherwise install everything unless individually disabled.
if [ -n "${INSTALL}" ]; then
    UV="false"
    POETRY="false"
    RUFF="false"
    MYPY="false"

    IFS=',' read -ra SELECTED <<< "${INSTALL}"
    for item in "${SELECTED[@]}"; do
        item="$(echo "$item" | xargs)"
        case "$item" in
            uv)     UV="true" ;;
            poetry) POETRY="true" ;;
            ruff)   RUFF="true" ;;
            mypy)   MYPY="true" ;;
            *) echo "Warning: unknown tool '$item' in install list" ;;
        esac
    done
fi

# uv - fast Python package manager
if [ "${UV}" != "false" ]; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | env INSTALLER_NO_MODIFY_PATH=1 sh
    # Make available system-wide
    ln -sf /root/.local/bin/uv /usr/local/bin/uv
    ln -sf /root/.local/bin/uvx /usr/local/bin/uvx
fi

# Poetry
if [ "${POETRY}" != "false" ]; then
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
if [ "${RUFF}" != "false" ]; then
    echo "Installing ruff..."
    pip install ruff
fi

# mypy - static type checker
if [ "${MYPY}" != "false" ]; then
    echo "Installing mypy..."
    pip install mypy
fi

echo "Python development tools installation complete."
