#!/bin/bash
set -e

echo "Installing Python development tools..."

# Step 1: All tools enabled by default
UV="true"
POETRY="true"
RUFF="true"
MYPY="true"

# Step 2: If install is set, whitelist mode
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

# Step 3: If omit is set, blacklist filter
if [ -n "${OMIT}" ]; then
    IFS=',' read -ra EXCLUDED <<< "${OMIT}"
    for item in "${EXCLUDED[@]}"; do
        item="$(echo "$item" | xargs)"
        case "$item" in
            uv)     UV="false" ;;
            poetry) POETRY="false" ;;
            ruff)   RUFF="false" ;;
            mypy)   MYPY="false" ;;
            *) echo "Warning: unknown tool '$item' in omit list" ;;
        esac
    done
fi

# uv - fast Python package manager
if [ "${UV}" = "true" ]; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | env INSTALLER_NO_MODIFY_PATH=1 sh
    # Copy to system-wide location (symlinks fail because /root is not accessible to non-root users)
    cp /root/.local/bin/uv /usr/local/bin/uv
    cp /root/.local/bin/uvx /usr/local/bin/uvx
    chmod 755 /usr/local/bin/uv /usr/local/bin/uvx
fi

# Poetry
if [ "${POETRY}" = "true" ]; then
    export POETRY_HOME=/opt/poetry
    if [ "${POETRYVERSION}" = "latest" ]; then
        echo "Installing Poetry (latest)..."
        curl -sSL https://install.python-poetry.org | python3 -
    else
        echo "Installing Poetry ${POETRYVERSION}..."
        curl -sSL https://install.python-poetry.org | python3 - --version "${POETRYVERSION}"
    fi
    ln -sf "${POETRY_HOME}/bin/poetry" /usr/local/bin/poetry

    # Configure in-project virtualenvs
    if [ "${INPROJECTVENVS}" = "true" ]; then
        su - "$_REMOTE_USER" -c 'poetry config virtualenvs.in-project true --global' || true
    fi
fi

# Prefer uv for installing Python tools; fall back to pip
if command -v uv >/dev/null 2>&1; then
    # Use UV_TOOL_DIR + UV_TOOL_BIN_DIR so tool venvs and binaries are world-accessible
    PY_INSTALL="env UV_TOOL_DIR=/opt/uv-tools UV_TOOL_BIN_DIR=/usr/local/bin uv tool install"
else
    PY_INSTALL="pip install --break-system-packages"
fi

# ruff - fast Python linter and formatter
if [ "${RUFF}" = "true" ]; then
    echo "Installing ruff..."
    $PY_INSTALL ruff
fi

# mypy - static type checker
if [ "${MYPY}" = "true" ]; then
    echo "Installing mypy..."
    $PY_INSTALL mypy
fi

echo "Python development tools installation complete."
