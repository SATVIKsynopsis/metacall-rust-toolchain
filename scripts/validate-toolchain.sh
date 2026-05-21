#!/usr/bin/env bash
set -euxo pipefail

apt update
apt install -y \
    curl \
    build-essential \
    xz-utils \
    cmake \
    ninja-build \
    pkg-config \
    libssl-dev

curl https://sh.rustup.rs -sSf | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"

mkdir -p /rust-dist
mkdir -p /patched-toolchain

for f in \
    /toolchain/dist/rustc-*-x86_64-unknown-linux-gnu.tar.xz \
    /toolchain/dist/rust-std-*.tar.xz \
    /toolchain/dist/cargo-*.tar.xz \
    /toolchain/dist/rustc-dev-*-x86_64-unknown-linux-gnu.tar.xz \
    /toolchain/dist/clippy-*.tar.xz \
    /toolchain/dist/rustfmt-*.tar.xz
do
    tar -xf "$f" -C /rust-dist
done

RUSTC_DIR=$(find /rust-dist -maxdepth 1 -type d -name "rustc-*" ! -name "rustc-dev-*")

"$RUSTC_DIR/install.sh" --prefix=/patched-toolchain
/rust-dist/rust-std-*/install.sh --prefix=/patched-toolchain
/rust-dist/cargo-*/install.sh --prefix=/patched-toolchain
/rust-dist/rustc-dev-*-x86_64-unknown-linux-gnu/install.sh --prefix=/patched-toolchain
/rust-dist/clippy-*/install.sh --prefix=/patched-toolchain
/rust-dist/rustfmt-*/install.sh --prefix=/patched-toolchain

find /patched-toolchain -name "librustc_driver*.so" 2>/dev/null
find /patched-toolchain -name "rustc_middle*" 2>/dev/null
find /patched-toolchain -name "rustc_hir*" 2>/dev/null
find /patched-toolchain -name "rustc_interface*" 2>/dev/null
find /patched-toolchain -name "*clippy*"
find /patched-toolchain -name "*rustfmt*"

ls /patched-toolchain/lib/rustlib/ 2>/dev/null || echo "no rustlib dir"

rustup toolchain link patched /patched-toolchain
rustup override set patched

rustc -Vv
cargo -V