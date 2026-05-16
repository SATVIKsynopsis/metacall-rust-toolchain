#!/usr/bin/env bash
set -euxo pipefail

apt update
apt install -y \
    curl \
    build-essential \
    xz-utils

curl https://sh.rustup.rs -sSf | sh -s -- -y

export PATH="$HOME/.cargo/bin:$PATH"

mkdir -p /rust-dist
mkdir -p /patched-toolchain

tar -xf /toolchain/rustc-*.tar.xz -C /rust-dist
tar -xf /toolchain/rust-std-*.tar.xz -C /rust-dist
tar -xf /toolchain/cargo-*.tar.xz -C /rust-dist

/rust-dist/rustc-*/install.sh --prefix=/patched-toolchain
/rust-dist/rust-std-*/install.sh --prefix=/patched-toolchain
/rust-dist/cargo-*/install.sh --prefix=/patched-toolchain

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