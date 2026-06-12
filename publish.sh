#!/usr/bin/env bash
#
# publish.sh — sync QA-passed (status: published) Obsidian notes into _posts/.
#
# This is the QA gate: only notes whose frontmatter says `status: published`
# ever land in the public site repo. draft / rejected / archived notes stay in
# the private vault and never get copied here.
#
# _posts/ is treated as fully owned by this script: it is WIPED and rebuilt from
# the current published set every run, so un-publishing a note (published →
# rejected) correctly removes it from the next build. Evergreen pages (about.md)
# live at repo root, NOT in _posts/, so they are untouched.
#
# Filename remap: vault `<source>-<YYYYMMDD>-<slug>.md`
#             →   _posts/`<YYYY-MM-DD>-<slug>.md`  (Jekyll requires the date prefix)
#
# Env:
#   VAULT_WEB  vault web folder (default: /Users/openclaw/srv/dropbox-vault/web)
#
set -euo pipefail

VAULT_WEB="${VAULT_WEB:-/Users/openclaw/srv/dropbox-vault/web}"
SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POSTS="$SITE_DIR/_posts"

if [ ! -d "$VAULT_WEB" ]; then
  echo "publish.sh: vault not found: $VAULT_WEB" >&2
  exit 1
fi

# fm <key> <file> — read a frontmatter scalar from the first --- block,
# stripping surrounding quotes. Empty string if absent.
fm() {
  awk -v k="$1" '
    /^---[[:space:]]*$/ { c++; next }
    c == 1 {
      i = index($0, ":")
      if (i == 0) next
      key = substr($0, 1, i - 1)
      gsub(/[[:space:]]/, "", key)
      if (key == k) {
        val = substr($0, i + 1)
        sub(/^[[:space:]]+/, "", val)
        gsub(/^"|"$/, "", val)
        print val
        exit
      }
    }
    c >= 2 { exit }
  ' "$2"
}

mkdir -p "$POSTS"
# wipe previously-synced posts (only *.md; _posts holds nothing else)
rm -f "$POSTS"/*.md

count=0
shopt -s nullglob
for f in "$VAULT_WEB"/*.md; do
  [ "$(fm status "$f")" = "published" ] || continue

  date="$(fm date "$f")"
  if [ -z "$date" ]; then
    echo "publish.sh: skip (no date): $(basename "$f")" >&2
    continue
  fi

  base="$(basename "$f" .md)"
  # slug = everything after the trailing -YYYYMMDD- group (source may contain dashes)
  slug="$(printf '%s' "$base" | sed -E 's/^.*-[0-9]{8}-//')"
  [ -n "$slug" ] && [ "$slug" != "$base" ] || slug="$base"

  target="$POSTS/${date}-${slug}.md"
  cp "$f" "$target"
  count=$((count + 1))
  echo "published → $(basename "$target")"
done

echo "publish.sh: synced $count published note(s) → _posts/"
