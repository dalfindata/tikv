#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${repo_root}"

echo "[tikv] validating Linux toolchain"
go version
rustc --version
cargo --version
cmake --version
protoc --version
clang --version | head -n 1
cargo metadata --locked --format-version 1 >/tmp/tikv-metadata.json
echo "[tikv] wrote cargo metadata to /tmp/tikv-metadata.json"
