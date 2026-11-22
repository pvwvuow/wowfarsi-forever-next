#!/usr/bin/env bash
# Build a release zip: scripts/release.sh 0.1.0
set -euo pipefail

VERSION="${1:?usage: release.sh <version>}"
NAME="WoWFN-v${VERSION}"
OUT="dist/${NAME}.zip"

mkdir -p dist
rm -f "dist/${NAME}.zip"

# syntax check every lua file first
fail=0
while IFS= read -r f; do
    luac5.4 -p "$f" || fail=1
done < <(find WoWFN -name '*.lua')
if [ "$fail" -ne 0 ]; then
    echo "syntax errors — aborting" >&2
    exit 1
fi

cp -r WoWFN "dist/${NAME}"
(cd dist && zip -qr "${NAME}.zip" "${NAME}" && rm -rf "${NAME}")
echo "built dist/${NAME}.zip"
