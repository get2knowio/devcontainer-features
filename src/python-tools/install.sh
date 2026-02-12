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

echo "Python development tools installation complete."
