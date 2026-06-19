# Dalfin Local Linux CI

This document describes how to test the Dalfin Linux CI commands for `tikv`
locally on an Apple silicon Mac using `apple/container`.

## Goal

Use a local Ubuntu environment on macOS to preflight Linux CI logic before
pushing workflow changes. This is a local Linux validation loop, not a full
replacement for GitHub-hosted Ubuntu checks.

## Host setup

Start the `container` service on macOS:

```bash
container system start
container system status
```

Create an Ubuntu container machine:

```bash
container machine create ubuntu:24.04 --name dalfin-ubuntu --cpus 4 --memory 8G
```

Open a shell:

```bash
container machine run -n dalfin-ubuntu
```

The default machine configuration mounts the macOS home directory read-write, so
the repo remains available under `/Users/<mac-user>/...`.

## Guest bootstrap

Inside the Ubuntu machine, install the native dependencies used by the current
Dalfin Linux checks:

```bash
sudo apt-get update
sudo apt-get install -y build-essential clang cmake curl git libclang-dev libssl-dev make pkg-config protobuf-compiler
```

Install Go:

```bash
curl -LO https://go.dev/dl/go1.25.10.linux-arm64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.25.10.linux-arm64.tar.gz
export PATH=/usr/local/go/bin:$PATH
go version
```

Install Rust and the pinned TiKV toolchain:

```bash
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"
rustup toolchain install nightly-2026-01-30 --profile minimal --component rustfmt --component clippy --component rust-src --component rust-analyzer
rustup default nightly-2026-01-30
```

## Run the local Linux checks

```bash
cd /Users/<mac-user>/Claude/Projects/DalfinDB/_worktrees/tikv-ci/dalfin-local-linux-support
./scripts/ci/dalfin-linux-toolchain.sh
./scripts/ci/dalfin-linux-check.sh
./scripts/ci/dalfin-linux-fmt.sh
```

## Notes

- `dalfin-linux-toolchain.sh` mirrors the environment-validation part of the
  current GitHub-hosted Linux workflow.
- `dalfin-linux-check.sh` mirrors the `cargo check` job body.
- `dalfin-linux-fmt.sh` mirrors the formatting check.
- Keep these scripts in sync with the workflow job commands so local Linux
  testing and GitHub-hosted Linux testing exercise the same entrypoints.
