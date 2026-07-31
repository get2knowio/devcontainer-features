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
check "zellij installed" bash -c "command -v zellij"
check "starship installed" bash -c "command -v starship"

# The eza aliases must still work when given a path argument. '--icons' takes an
# optional value in eza >= 0.15.0, so an unattached value swallows the path.
touch /tmp/eza-alias-probe.txt
check "ls alias accepts a path argument" zsh -ic "ls /tmp/eza-alias-probe.txt"
check "ll alias accepts a path argument" zsh -ic "ll /tmp/eza-alias-probe.txt"
check "la alias accepts a path argument" zsh -ic "la /tmp/eza-alias-probe.txt"

reportResults
