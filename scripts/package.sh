#!/usr/bin/env bash
# Package each skill folder into a zip for uploading to claude.ai.
# Usage: ./scripts/package.sh            (all skills)
#        ./scripts/package.sh <name>     (one skill)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist"
mkdir -p "$OUT"

shopt -s nullglob
all=("$ROOT"/plugins/*/skills/*/)

for dir in "${all[@]}"; do
  dir="${dir%/}"
  name="$(basename "$dir")"
  if [ $# -gt 0 ] && [[ ! " $* " == *" $name "* ]]; then continue; fi
  if [ ! -f "$dir/SKILL.md" ]; then
    echo "skip: $name (no SKILL.md)" >&2
    continue
  fi
  rm -f "$OUT/$name.zip"
  (cd "$(dirname "$dir")" && zip -qr "$OUT/$name.zip" "$name")
  echo "built: dist/$name.zip"
done
