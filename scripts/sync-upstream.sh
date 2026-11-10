#!/usr/bin/env bash
# Pull the latest version of every vendored skill from its upstream repo.
# Each vendored skill folder has an UPSTREAM.md; the list below maps it to its source.
# Review `git diff` before committing.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# repo | path in upstream repo | path in this repo
VENDORED=(
  "forrestchang/andrej-karpathy-skills|skills/karpathy-guidelines|plugins/coding/skills/karpathy-guidelines"
  "mattpocock/skills|skills/misc/git-guardrails-claude-code|plugins/coding/skills/git-guardrails-claude-code"
  "mattpocock/skills|skills/productivity/grill-me|plugins/productivity/skills/grill-me"
  "mattpocock/skills|skills/productivity/grilling|plugins/productivity/skills/grilling"
  "mattpocock/skills|skills/productivity/handoff|plugins/productivity/skills/handoff"
  "mattpocock/skills|skills/productivity/writing-for-agents|plugins/productivity/skills/writing-for-agents"
  "cloudflare/security-audit-skill|skills/security-audit|plugins/security/skills/security-audit"
)

for entry in "${VENDORED[@]}"; do
  IFS='|' read -r repo src dest <<< "$entry"
  clone="$TMP/${repo//\//__}"
  if [ ! -d "$clone" ]; then
    git clone -q --depth=1 "https://github.com/$repo.git" "$clone"
  fi
  if [ ! -d "$clone/$src" ]; then
    echo "WARN: $repo no longer has $src; skipping $dest" >&2
    continue
  fi

  dest_abs="$ROOT/$dest"
  keep="$(mktemp)"
  cp "$dest_abs/UPSTREAM.md" "$keep"
  rm -rf "$dest_abs"
  mkdir -p "$dest_abs"
  cp -R "$clone/$src/." "$dest_abs/"
  mv "$keep" "$dest_abs/UPSTREAM.md"

  sha="$(git -C "$clone" log -1 --format='%H')"
  date="$(git -C "$clone" log -1 --format='%cs')"
  sed -i.bak -E "s/^- Commit: .*/- Commit: \`$sha\` ($date)/" "$dest_abs/UPSTREAM.md"
  rm -f "$dest_abs/UPSTREAM.md.bak"
  echo "synced: $dest <- $repo@${sha:0:7}"
done
