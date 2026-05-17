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

tar -xf /toolchain/dist/rustc-*.tar.xz -C /rust-dist
tar -xf /toolchain/dist/rust-std-*.tar.xz -C /rust-dist
tar -xf /toolchain/dist/cargo-*.tar.xz -C /rust-dist
tar -xf /toolchain/dist/rustc-dev-*.tar.xz -C /rust-dist

/rust-dist/rustc-*/install.sh --prefix=/patched-toolchain
/rust-dist/rust-std-*/install.sh --prefix=/patched-toolchain
/rust-dist/cargo-*/install.sh --prefix=/patched-toolchain
/rust-dist/rustc-dev-*/install.sh --prefix=/patched-toolchain

rustup toolchain link patched /patched-toolchain
rustup override set patched

rustc -Vv
cargo -V

cargo new hello
cd hello

cat > src/main.rs <<EOF
fn main() {
    println!("patched rust toolchain works");
}
EOF

cargo build -v
./target/debug/hello