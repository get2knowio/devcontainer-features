#!/bin/bash
set -e

echo "Installing modern CLI tools..."

ARCH=$(dpkg --print-architecture)

# --- APT-based tools ---
APT_PACKAGES=""
if [ "${BAT}" = "true" ]; then APT_PACKAGES="$APT_PACKAGES bat"; fi
if [ "${RIPGREP}" = "true" ]; then APT_PACKAGES="$APT_PACKAGES ripgrep"; fi
if [ "${FD}" = "true" ]; then APT_PACKAGES="$APT_PACKAGES fd-find"; fi
if [ "${FZF}" = "true" ]; then APT_PACKAGES="$APT_PACKAGES fzf"; fi
if [ "${NEOVIM}" = "true" ]; then APT_PACKAGES="$APT_PACKAGES neovim"; fi
if [ "${TMUX}" = "true" ]; then APT_PACKAGES="$APT_PACKAGES tmux"; fi

if [ -n "$APT_PACKAGES" ]; then
    apt-get update -y
    apt-get install -y --no-install-recommends $APT_PACKAGES
    apt-get clean
    rm -rf /var/lib/apt/lists/*
fi

# Create symlinks for apt tools
if [ "${BAT}" = "true" ] && [ -f /usr/bin/batcat ]; then
    ln -sf /usr/bin/batcat /usr/bin/bat
fi
if [ "${FD}" = "true" ] && [ -f /usr/bin/fdfind ]; then
    ln -sf /usr/bin/fdfind /usr/bin/fd
fi

# --- GitHub release tools ---

# eza
if [ "${EZA}" = "true" ]; then
    echo "Installing eza..."
    case "$ARCH" in
        amd64) EZA_ARCH="x86_64" ;;
        arm64) EZA_ARCH="aarch64" ;;
        *) echo "Unsupported architecture for eza: $ARCH" && exit 1 ;;
    esac
    if [ "${EZAVERSION}" = "latest" ]; then
        EZA_TAR_URL="https://github.com/eza-community/eza/releases/latest/download/eza_${EZA_ARCH}-unknown-linux-gnu.tar.gz"
    else
        EZA_TAR_URL="https://github.com/eza-community/eza/releases/download/v${EZAVERSION}/eza_${EZA_ARCH}-unknown-linux-gnu.tar.gz"
    fi
    curl -fsSL "$EZA_TAR_URL" | tar -xzf - -C /usr/local/bin/
fi

# zoxide
if [ "${ZOXIDE}" = "true" ]; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- -b /usr/local/bin
fi

# lazygit
if [ "${LAZYGIT}" = "true" ]; then
    echo "Installing lazygit ${LAZYGITVERSION}..."
    case "$ARCH" in
        amd64) LG_ARCH="x86_64" ;;
        arm64) LG_ARCH="arm64" ;;
        *) echo "Unsupported architecture for lazygit: $ARCH" && exit 1 ;;
    esac
    LG_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGITVERSION}/lazygit_${LAZYGITVERSION}_Linux_${LG_ARCH}.tar.gz"
    curl -fsSL "$LG_URL" -o /tmp/lazygit.tgz
    tar -xzf /tmp/lazygit.tgz -C /tmp lazygit
    install /tmp/lazygit /usr/local/bin/lazygit
    rm -f /tmp/lazygit.tgz /tmp/lazygit
fi

# ast-grep
if [ "${ASTGREP}" = "true" ]; then
    echo "Installing ast-grep ${ASTGREPVERSION}..."
    case "$ARCH" in
        amd64) SG_ARCH="x86_64" ;;
        arm64) SG_ARCH="aarch64" ;;
        *) echo "Unsupported architecture for ast-grep: $ARCH" && exit 1 ;;
    esac
    AST_GREP_URL="https://github.com/ast-grep/ast-grep/releases/download/${ASTGREPVERSION}/app-${SG_ARCH}-unknown-linux-gnu.zip"
    curl -fsSL "$AST_GREP_URL" -o /tmp/ast-grep.zip
    unzip -q /tmp/ast-grep.zip -d /tmp/ast-grep
    install /tmp/ast-grep/sg /usr/local/bin/sg
    install /tmp/ast-grep/ast-grep /usr/local/bin/ast-grep 2>/dev/null || cp /tmp/ast-grep/sg /usr/local/bin/ast-grep
    rm -rf /tmp/ast-grep.zip /tmp/ast-grep
fi

# zellij (optional, default false)
if [ "${ZELLIJ}" = "true" ]; then
    echo "Installing zellij ${ZELLIJVERSION}..."
    case "$ARCH" in
        amd64) ZELLIJ_ARCH="x86_64" ;;
        arm64) ZELLIJ_ARCH="aarch64" ;;
        *) echo "Unsupported architecture for zellij: $ARCH" && exit 1 ;;
    esac
    ZELLIJ_URL="https://github.com/zellij-org/zellij/releases/download/v${ZELLIJVERSION}/zellij-${ZELLIJ_ARCH}-unknown-linux-musl.tar.gz"
    curl -fsSL "$ZELLIJ_URL" -o /tmp/zellij.tgz
    tar -xzf /tmp/zellij.tgz -C /usr/local/bin zellij
    rm -f /tmp/zellij.tgz
fi

# --- Shell configuration ---
ZSHRC="$_REMOTE_USER_HOME/.zshrc"

if [ "${EZA}" = "true" ]; then
    echo 'alias ls="eza --icons"' >> "$ZSHRC"
    echo 'alias ll="eza -l --icons"' >> "$ZSHRC"
    echo 'alias la="eza -la --icons"' >> "$ZSHRC"
fi

if [ "${ZOXIDE}" = "true" ]; then
    echo 'eval "$(zoxide init zsh)"' >> "$ZSHRC"
fi

echo "Modern CLI tools installation complete."
