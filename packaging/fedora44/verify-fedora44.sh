#!/usr/bin/env bash
set -euo pipefail

source_dir="${1:?uso: verify-fedora44.sh <código-fonte>}"
cd "$source_dir"
test_bin="out/fedora/dbg/test_engines"
app_bin="out/fedora/rel/SumatraPDF"
test -x "$test_bin"
test -x "$app_bin"

mkdir -p out/fedora/verification
for sample in zlib.3.pdf test.epub test.cbz test.djvu test.png; do
    "$test_bin" "docs/test/$sample" "out/fedora/verification/$sample.png" 1
    test -s "out/fedora/verification/$sample.png"
done

"$test_bin" docs/test/test.chm -model-toc >out/fedora/verification/chm.txt
grep -Fq 'model: .chm, pages: 1' out/fedora/verification/chm.txt
"$test_bin" tests/issue-2254.fb2 out/fedora/verification/fb2.png 1
test -s out/fedora/verification/fb2.png

"$app_bin" -for-testing -silent -print-to PDF \
    -print-settings 'output=out/fedora/verification/azw3.pdf' \
    tests/issue-4315.azw3
"$test_bin" out/fedora/verification/azw3.pdf \
    out/fedora/verification/azw3.png 1 >out/fedora/verification/azw3.txt
grep -q 'pages: 3' out/fedora/verification/azw3.txt

"$app_bin" -for-testing -silent -print-to PDF \
    -print-settings '1,landscape,dpi=72,output=out/fedora/verification/print.pdf' \
    docs/test/zlib.3.pdf
"$test_bin" out/fedora/verification/print.pdf \
    out/fedora/verification/print.png 1 >out/fedora/verification/print.txt
grep -q 'pages: 1' out/fedora/verification/print.txt
grep -q 'page 1: 792 x 612' out/fedora/verification/print.txt

echo 'Renderização e impressão verificadas no Fedora 44.'
