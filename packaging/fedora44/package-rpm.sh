#!/usr/bin/env bash
set -euo pipefail

source_dir="${1:?uso: package-rpm.sh <código-fonte> <diretório-de-saída>}"
output_dir="${2:?uso: package-rpm.sh <código-fonte> <diretório-de-saída>}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! . /etc/os-release || [[ "${ID:-}" != fedora || "${VERSION_ID:-}" != 44 ]]; then
    echo "O RPM deve ser empacotado no Fedora 44." >&2
    exit 1
fi

version="$(sed -n 's/^Version:[[:space:]]*//p' "$script_dir/sumatrapdf.spec")"
exe="$source_dir/out/fedora/rel/SumatraPDF"
if [[ ! -x "$exe" ]]; then
    echo "Executável ausente: $exe" >&2
    exit 1
fi

mkdir -p "$output_dir"
output_dir="$(cd "$output_dir" && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
top_dir="$tmp_dir/rpmbuild"
stage_dir="$tmp_dir/sumatrapdf-$version"
mkdir -p "$top_dir"/{SOURCES,SPECS,BUILD,BUILDROOT,RPMS,SRPMS} "$stage_dir/icons"

cp "$exe" "$stage_dir/SumatraPDF"
cp "$source_dir/src/ng/linux/sumatrapdf.desktop" "$stage_dir/"
cp "$source_dir/src/ng/linux/sumatrapdf.xml" "$stage_dir/"
cp "$source_dir/src/ng/linux/icons/"*.png "$stage_dir/icons/"
cp "$source_dir/COPYING" "$source_dir/AUTHORS" "$stage_dir/"
printf 'Git commit: %s\nPatch SHA256: %s\nBuilt on: Fedora 44\n' \
    "$(git -C "$source_dir" rev-parse HEAD)" \
    "$(git -C "$source_dir" diff --binary | sha256sum | cut -d ' ' -f 1)" >"$stage_dir/BUILD-INFO"

tar -C "$tmp_dir" -czf "$top_dir/SOURCES/sumatrapdf-$version.tar.gz" "sumatrapdf-$version"
cp "$script_dir/sumatrapdf.spec" "$top_dir/SPECS/"
rpmbuild -bb --define "_topdir $top_dir" "$top_dir/SPECS/sumatrapdf.spec"
find "$top_dir/RPMS" -type f -name '*.rpm' -exec cp {} "$output_dir/" \;
sha256sum "$output_dir"/*.rpm
