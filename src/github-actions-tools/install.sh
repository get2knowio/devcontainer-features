#!/bin/bash
set -e

echo "Installing GitHub Actions tools..."

ARCH=$(dpkg --print-architecture)

# If 'install' is set, only install the listed tools (comma-separated).
# Otherwise install everything unless individually disabled.
if [ -n "${INSTALL}" ]; then
    ACT="false"
    ACTIONLINT="false"

    IFS=',' read -ra SELECTED <<< "${INSTALL}"
    for item in "${SELECTED[@]}"; do
        item="$(echo "$item" | xargs)"
        case "$item" in
            act)        ACT="true" ;;
            actionlint) ACTIONLINT="true" ;;
            *) echo "Warning: unknown tool '$item' in install list" ;;
        esac
    done
fi

# act - run GitHub Actions locally
if [ "${ACT}" != "false" ]; then
    echo "Installing act ${ACTVERSION}..."
    case "$ARCH" in
        amd64) ACT_ARCH="x86_64" ;;
        arm64) ACT_ARCH="arm64" ;;
        *) echo "Unsupported architecture for act: $ARCH" && exit 1 ;;
    esac
    ACT_URL="https://github.com/nektos/act/releases/download/v${ACTVERSION}/act_Linux_${ACT_ARCH}.tar.gz"
    curl -fsSL "$ACT_URL" | tar -xz -C /usr/local/bin act
    chmod +x /usr/local/bin/act
fi

# actionlint - GitHub Actions workflow linter
if [ "${ACTIONLINT}" != "false" ]; then
    echo "Installing actionlint ${ACTIONLINTVERSION}..."
    case "$ARCH" in
        amd64) ACTIONLINT_ARCH="amd64" ;;
        arm64) ACTIONLINT_ARCH="arm64" ;;
        *) echo "Unsupported architecture for actionlint: $ARCH" && exit 1 ;;
    esac
    ACTIONLINT_URL="https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINTVERSION}/actionlint_${ACTIONLINTVERSION}_linux_${ACTIONLINT_ARCH}.tar.gz"
    curl -fsSL "$ACTIONLINT_URL" | tar -xz -C /usr/local/bin actionlint
    chmod +x /usr/local/bin/actionlint
fi

echo "GitHub Actions tools installation complete."
