#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin

download_github_release() {
	wget -nv \
		--tries=5 \
		--waitretry=10 \
		--timeout=30 \
		--retry-connrefused \
		--retry-on-http-error=429,500,502,503,504 \
		-O "$1" \
		"$2"
}

download_github_release ~/.byond/bin/librust_g.so "https://github.com/tgstation/rust-g/releases/download/$RUST_G_VERSION/librust_g.so"
chmod +x ~/.byond/bin/librust_g.so
ldd ~/.byond/bin/librust_g.so

download_github_release ~/.byond/bin/librust_utils.so "https://github.com/ss220club/rust-utils/releases/download/$RUST_UTILS_VERSION/librust_utils.so"
chmod +x ~/.byond/bin/librust_utils.so
ldd ~/.byond/bin/librust_utils.so
