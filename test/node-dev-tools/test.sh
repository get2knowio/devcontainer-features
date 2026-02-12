#!/bin/bash
set -e
source dev-container-features-test-lib

check "typescript installed" bash -c "command -v tsc"
check "ts-node installed" bash -c "command -v ts-node"
check "tsx installed" bash -c "command -v tsx"
check "vite installed" bash -c "command -v vite"
check "esbuild installed" bash -c "command -v esbuild"
check "prettier installed" bash -c "command -v prettier"
check "eslint installed" bash -c "command -v eslint"
check "biome installed" bash -c "command -v biome"
check "nodemon installed" bash -c "command -v nodemon"
check "bun installed" bash -c "command -v bun"

reportResults
