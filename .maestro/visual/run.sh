#!/bin/bash
# Chạy một flow visual và gom ảnh về .maestro/visual/out/<...>.png
# Dùng: .maestro/visual/run.sh <flow> [API_URL]   (vd: run.sh baseline)
# Ảnh trong flow khai báo `takeScreenshot: out/<nhóm>/<tên>` → .maestro/visual/out/<nhóm>/<tên>.png
set -euo pipefail
cd "$(dirname "$0")"
flow="${1:?flow name}"
api="${2:-http://localhost:8081}"
tmp="$(mktemp -d)"
~/.maestro/bin/maestro test "$flow.yaml" -e APP_ID=com.namtruong244.inventory -e API_URL="$api" --test-output-dir "$tmp" || rc=$?
src="$(find "$tmp" -type d -path '*takeScreenshot/out' | head -1)"
if [ -n "$src" ]; then mkdir -p out && cp -R "$src"/. out/; fi
rm -rf "$tmp"
exit "${rc:-0}"
