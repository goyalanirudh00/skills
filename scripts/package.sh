#!/usr/bin/env bash
# Package each skill folder into a zip for uploading to claude.ai.
# Usage: ./scripts/package.sh            (all skills)
#        ./scripts/package.sh <name>     (one skill)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist"
mkdir -p "$OUT"

if [ $# -gt 0 ]; then
  names=("$@")
else
  names=()
  for d in "$ROOT"/skills/*/; do names+=("$(basename "$d")"); done
fi

for name in "${names[@]}"; do
  src="$ROOT/skills/$name"
  if [ ! -f "$src/SKILL.md" ]; then
    echo "skip: $name (no SKILL.md)" >&2
    continue
  fi
  rm -f "$OUT/$name.zip"
  (cd "$ROOT/skills" && zip -qr "$OUT/$name.zip" "$name")
  echo "built: dist/$name.zip"
done
