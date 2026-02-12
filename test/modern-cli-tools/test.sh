#!/bin/bash
set -e
source dev-container-features-test-lib

check "bat installed" bash -c "command -v bat"
check "ripgrep installed" bash -c "command -v rg"
check "fd installed" bash -c "command -v fd"
check "fzf installed" bash -c "command -v fzf"
check "eza installed" bash -c "command -v eza"
check "zoxide installed" bash -c "command -v zoxide"
check "neovim installed" bash -c "command -v nvim"
check "tmux installed" bash -c "command -v tmux"
check "lazygit installed" bash -c "command -v lazygit"
check "ast-grep installed" bash -c "command -v sg"
check "jujutsu installed" bash -c "command -v jj"

reportResults
