#!/usr/bin/env bash
set -euxo pipefail

RUST_COMMIT="af302a67fdc508cfd08ee22facb96bcf0e5bf831"

apt update
apt install -y \
    git \
    curl \
    python3 \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    libssl-dev 

git clone https://github.com/rust-lang/rust.git
cd rust

git checkout ${RUST_COMMIT}

cat > config.toml <<EOF
[llvm]
download-ci-llvm = true

[build]
extended = true

[rust]
codegen-units = 1
EOF

grep -R "tls-model=initial-exec" src || true

sed -i '/tls-model=initial-exec/d' src/bootstrap/src/bin/rustc.rs

grep -R "tls-model=initial-exec" src || true

python3 x.py dist --stage 2 rustc rust-std cargo