#!/usr/bin/env bash
# discover.sh — scan for git repos and doc conventions; emit JSON for /dmg --init
set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo '{"error":"jq not found — install it first: https://jqlang.org/download/"}'; exit 1; }

MAXDEPTH=5
NAMED_DOCS=("README.md" "CLAUDE.md" "AGENTS.md")
GLOB_DOCS=("AGENTS-*.md")

repo_doc_files() {
  local dir="$1"
  local found=()
  for f in "${NAMED_DOCS[@]}"; do
    [[ -f "$dir/$f" ]] && found+=("$f")
  done
  shopt -s nullglob
  for glob in "${GLOB_DOCS[@]}"; do
    for f in "$dir"/$glob; do
      [[ -f "$f" ]] && found+=("$(basename "$f")")
    done
  done
  shopt -u nullglob
  [[ -d "$dir/docs" ]] && found+=("docs/")
  printf '%s\n' "${found[@]}" | sort -u | jq -R . | jq -s .
}

parent_repo() {
  local dir
  dir=$(dirname "$1")
  while [[ "$dir" != "/" && "$dir" != "$HOME" ]]; do
    [[ -d "$dir/.git" ]] && { echo "$dir"; return; }
    dir=$(dirname "$dir")
  done
  echo ""
}

repos=()
while IFS= read -r git_dir; do
  repo_path="${git_dir%/.git}"
  name=$(basename "$repo_path")
  parent=$(parent_repo "$repo_path")
  doc_files=$(repo_doc_files "$repo_path")
  entry=$(jq -n \
    --arg path "$repo_path" \
    --arg name "$name" \
    --arg nested_in "$parent" \
    --argjson doc_files "$doc_files" \
    '{path: $path, name: $name, nested_in: $nested_in, doc_files: $doc_files}')
  repos+=("$entry")
done < <(
  find "$HOME" -maxdepth "$MAXDEPTH" \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/vendor/*" \
    -not -path "*/venv/*" \
    -not -path "*/.venv/*" \
    -not -path "*/__pycache__/*" \
    -not -path "*/.local/*" \
    -not -path "*/.cache/*" \
    -not -path "*/.npm/*" \
    -name ".git" -type d 2>/dev/null | sort
)

repos_json=$(
  if [[ ${#repos[@]} -gt 0 ]]; then
    printf '%s\n' "${repos[@]}" | jq -s .
  else
    echo "[]"
  fi
)

memory_json=$(
  find "$HOME/.claude/projects" -name "MEMORY.md" 2>/dev/null | sort | jq -R . | jq -s .
)

skill_path="$HOME/.claude/skills/dmg/SKILL.md"
skill_exists=$([[ -f "$skill_path" ]] && echo true || echo false)

jq -n \
  --argjson repos "$repos_json" \
  --argjson memory_paths "$memory_json" \
  --argjson skill_exists "$skill_exists" \
  '{repos: $repos, memory_paths: $memory_paths, skill_exists: $skill_exists}'
