#!/usr/bin/env bash
set -euo pipefail

# Build the upstream SumatraPDF ng Linux target on Fedora 44.
# Pass an existing source checkout as the first argument, or let this script
# clone the official repository into the current directory.

if ! . /etc/os-release || [[ "${ID:-}" != fedora || "${VERSION_ID:-}" != 44 ]]; then
    echo "Este instalador requer Fedora 44." >&2
    exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_revision="1950ed5bbe538c9897a1cf55336c52b9ca64d680"
source_dir="${1:-$PWD/sumatrapdf}"
root_cmd=()
if [[ "$(id -u)" != 0 ]]; then
    root_cmd=(sudo)
fi
if [[ ! -d "$source_dir/.git" ]]; then
    if [[ -e "$source_dir" ]]; then
        echo "O destino existe, mas não é um checkout Git: $source_dir" >&2
        exit 1
    fi
    git clone --depth=1 https://github.com/sumatrapdfreader/sumatrapdf.git "$source_dir"
fi

cd "$source_dir"
if [[ "$(git rev-parse HEAD)" != "$source_revision" ]]; then
    git fetch --depth=1 origin "$source_revision"
    git checkout --detach "$source_revision"
fi
if ! git apply --reverse --check "$script_dir/fedora44-fixes.patch" 2>/dev/null; then
    git apply --check "$script_dir/fedora44-fixes.patch"
    git apply "$script_dir/fedora44-fixes.patch"
fi

if [[ ! -f cmd/fedora-install.ts || ! -f src/ng/README.md ]]; then
    echo "O checkout não contém o port Linux do SumatraPDF." >&2
    exit 1
fi

if ! command -v bun >/dev/null 2>&1; then
    echo "Instale Bun antes de executar este script: https://bun.sh/docs/installation" >&2
    exit 1
fi

if ! rpm -q glibc-gconv-extra >/dev/null 2>&1; then
    "${root_cmd[@]}" dnf install -y glibc-gconv-extra
fi

echo "Fonte: $(git rev-parse HEAD)"
bun cmd/fedora-install.ts
NG_LINUX_OUT=fedora bun cmd/ng-build.ts -dbg test_util -run -- -for-ai
"${root_cmd[@]}" ln -sfn SumatraPDF /usr/local/bin/sumatrapdf

# The upstream Fedora installer installs the executable only. Register its
# desktop entry, MIME types and icons for Fedora's application menus.
"${root_cmd[@]}" install -Dm644 src/ng/linux/sumatrapdf.desktop \
    /usr/local/share/applications/sumatrapdf.desktop
"${root_cmd[@]}" install -Dm644 src/ng/linux/sumatrapdf.xml \
    /usr/local/share/mime/packages/sumatrapdf.xml
for size in 16 24 32 48 64 128 256; do
    "${root_cmd[@]}" install -Dm644 "src/ng/linux/icons/sumatrapdf-${size}.png" \
        "/usr/local/share/icons/hicolor/${size}x${size}/apps/sumatrapdf.png"
done
if command -v update-mime-database >/dev/null 2>&1; then
    "${root_cmd[@]}" update-mime-database /usr/local/share/mime
fi
if command -v update-desktop-database >/dev/null 2>&1; then
    "${root_cmd[@]}" update-desktop-database /usr/local/share/applications
fi

echo "Instalado: /usr/local/bin/SumatraPDF (também /usr/local/bin/sumatrapdf)"
