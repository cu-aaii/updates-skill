#!/usr/bin/env bash
# Informs the update: lists recent Claude Code sessions and git commits, grouped by working directory.
# Usage: inform.sh [days]   (default 7)
# Requires: jq, git
set -euo pipefail

days="${1:-7}"
projects="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
since_git="$days days ago"

command -v jq >/dev/null || { echo "error: jq is required" >&2; exit 1; }
[ -d "$projects" ] || { echo "error: no transcripts at $projects" >&2; exit 1; }

# One TSV row per session: cwd, last timestamp, title, first prompt.
rows="$(
  find "$projects" -name '*.jsonl' -not -path '*/subagents/*' -mtime "-$days" -print0 |
    xargs -0 -I{} jq -rs '
      (map(select(.type == "user" and .cwd)) ) as $u
      | select($u | length > 0)
      | ((map(select(.type == "custom-title") | .customTitle) + map(select(.type == "ai-title") | .aiTitle)) | last // "untitled") as $title
      | ($u | map(select(.message.content | type == "string") | .message.content
                  | select(startswith("<") | not)) | first // "" ) as $first
      | [$u[0].cwd, ($u | last | .timestamp), $title, ($first | gsub("[\\t\\n\\r]+"; " ") | .[0:160])]
      | @tsv
    ' {} 2>/dev/null || true
)"

if [ -z "$rows" ]; then
  echo "No Claude Code sessions in the last $days days."
  exit 0
fi

echo "# Activity, last $days days"
echo

printf '%s\n' "$rows" | cut -f1 | sort -u | while IFS= read -r cwd; do
  echo "## $cwd"
  printf '%s\n' "$rows" | awk -F'\t' -v d="$cwd" '$1 == d' | sort -t$'\t' -k2 |
    while IFS=$'\t' read -r _ ts title first; do
      echo "- ${ts%%T*} session: $title"
      [ -n "$first" ] && echo "  prompt: $first"
    done
  if [ -d "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    author="$(git -C "$cwd" config user.email || true)"
    commits="$(git -C "$cwd" log --all --no-merges --since="$since_git" ${author:+--author="$author"} \
      --format='- %as commit: %s' 2>/dev/null || true)"
    [ -n "$commits" ] && printf '%s\n' "$commits"
  fi
  echo
done
