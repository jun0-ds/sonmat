#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "$SCRIPT_DIR/../codex/agents" && pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
TARGET_DIR="$CODEX_HOME_DIR/agents"
FORCE=false
DRY_RUN=false

usage() {
  printf 'Usage: %s [--force] [--dry-run]\n' "$0"
}

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done

AGENTS=(sonmat_worker sonmat_witness sonmat_scribe)

# Preflight every destination before writing anything, so one local override
# cannot leave the installation half-updated.
for agent in "${AGENTS[@]}"; do
  source_file="$SOURCE_DIR/$agent.toml"
  target_file="$TARGET_DIR/$agent.toml"
  if [ ! -f "$source_file" ]; then
    printf 'Missing packaged agent: %s\n' "$source_file" >&2
    exit 1
  fi
  if [ -e "$target_file" ] && ! cmp -s "$source_file" "$target_file" && [ "$FORCE" = false ]; then
    printf 'Refusing to overwrite modified agent: %s\n' "$target_file" >&2
    printf 'Review the diff, then rerun with --force if replacement is intended.\n' >&2
    exit 3
  fi
done

if [ "$DRY_RUN" = true ]; then
  printf 'Would install %s into %s\n' "${AGENTS[*]}" "$TARGET_DIR"
  exit 0
fi

mkdir -p "$TARGET_DIR"
for agent in "${AGENTS[@]}"; do
  source_file="$SOURCE_DIR/$agent.toml"
  target_file="$TARGET_DIR/$agent.toml"
  if cmp -s "$source_file" "$target_file" 2>/dev/null; then
    printf 'Unchanged: %s\n' "$target_file"
    continue
  fi
  temp_file="$(mktemp "$TARGET_DIR/.${agent}.toml.XXXXXX")"
  cp "$source_file" "$temp_file"
  chmod 600 "$temp_file"
  mv "$temp_file" "$target_file"
  printf 'Installed: %s\n' "$target_file"
done
