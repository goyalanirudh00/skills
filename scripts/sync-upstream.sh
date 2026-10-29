#!/usr/bin/env bash
# Pull the latest karpathy-guidelines skill from upstream. Review `git diff` before committing.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/plugins/coding/skills/karpathy-guidelines"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone -q --depth=1 https://github.com/forrestchang/andrej-karpathy-skills.git "$TMP/repo"
cp "$TMP/repo/skills/karpathy-guidelines/SKILL.md" "$DEST/SKILL.md"
SHA="$(git -C "$TMP/repo" log -1 --format='%H')"
DATE="$(git -C "$TMP/repo" log -1 --format='%cs')"
sed -i.bak -E "s/^- Commit: .*/- Commit: \`$SHA\` ($DATE)/" "$DEST/UPSTREAM.md" && rm -f "$DEST/UPSTREAM.md.bak"
echo "Synced karpathy-guidelines to $SHA ($DATE)"
