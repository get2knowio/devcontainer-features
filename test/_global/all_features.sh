#!/bin/bash
set -e
source dev-container-features-test-lib

# Smoke test one tool from each feature
check "ai-clis: gemini" bash -c "command -v gemini"
check "modern-cli-tools: bat" bash -c "command -v bat"
check "node-dev-tools: tsc" bash -c "command -v tsc"
check "rust-dev-tools: bacon" bash -c "command -v bacon"
check "github-actions-tools: act" bash -c "command -v act"
check "python-tools: poetry" bash -c "command -v poetry"

reportResults
