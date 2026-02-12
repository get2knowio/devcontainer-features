#!/bin/bash
set -e

echo "Setting up DevContainer feature development environment..."

# Install DevContainer CLI globally
echo "Installing DevContainer CLI..."
npm install -g @devcontainers/cli

# Verify installation
echo "DevContainer CLI version:"
devcontainer --version

# Verify Docker access
echo "Verifying Docker access..."
docker version --format '{{.Server.Version}}'

echo ""
echo "Development environment ready!"
echo ""
echo "Available commands:"
echo "  devcontainer features test --features <name> .    # Test a single feature"
echo "  devcontainer features test --global-scenarios-only .  # Test all features together"
echo "  devcontainer features test .                      # Run all tests"
