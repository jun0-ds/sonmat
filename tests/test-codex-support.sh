#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

run_hook() {
  local home_dir="$1"
  local project_dir="$2"
  local plugin_data="$3"
  (
    cd "$project_dir"
    HOME="$home_dir" \
      PLUGIN_DATA="$plugin_data" \
      CODEX_HOME="$home_dir/.codex" \
      SONMAT_HOME="$home_dir/.sonmat" \
      SONMAT_PROJECTS_BASE="$home_dir/state/projects" \
      SONMAT_MEMORY_DIR="$home_dir/state/memory" \
      bash "$REPO_ROOT/hooks/session-start"
  )
}

# Codex: engage discipline, report missing agents, and never mutate Claude files.
CODEX_HOME_TEST="$TEST_ROOT/codex-home"
CODEX_PROJECT="$TEST_ROOT/codex-project"
mkdir -p "$CODEX_HOME_TEST/.claude" "$CODEX_HOME_TEST/.sonmat" "$CODEX_PROJECT/.git"
printf 'keep-me\n' > "$CODEX_HOME_TEST/.claude/CLAUDE.md"
date +%s > "$CODEX_HOME_TEST/.sonmat/.last_update_check"
CODEX_OUTPUT="$(run_hook "$CODEX_HOME_TEST" "$CODEX_PROJECT" "$TEST_ROOT/plugin-data")"
grep -q 'sonmat: read ' <<< "$CODEX_OUTPUT"
grep -q 'sonmat Codex agents are not installed' <<< "$CODEX_OUTPUT"
grep -qx 'keep-me' "$CODEX_HOME_TEST/.claude/CLAUDE.md"
test ! -e "$CODEX_PROJECT/CLAUDE.md"

# Agent installer: install all files, remain idempotent, and refuse local drift.
INSTALL_HOME="$TEST_ROOT/install-home"
CODEX_HOME="$INSTALL_HOME/.codex" bash "$REPO_ROOT/scripts/install-codex-agents.sh"
for agent in sonmat_worker sonmat_witness sonmat_scribe; do
  cmp "$REPO_ROOT/codex/agents/$agent.toml" "$INSTALL_HOME/.codex/agents/$agent.toml"
done
CODEX_HOME="$INSTALL_HOME/.codex" bash "$REPO_ROOT/scripts/install-codex-agents.sh" >/dev/null
printf '\n# local override\n' >> "$INSTALL_HOME/.codex/agents/sonmat_worker.toml"
if CODEX_HOME="$INSTALL_HOME/.codex" bash "$REPO_ROOT/scripts/install-codex-agents.sh" >/dev/null 2>&1; then
  printf 'installer overwrote or accepted a modified agent without --force\n' >&2
  exit 1
fi

# Claude Code: preserve the existing project/global bootstrap behavior.
CLAUDE_HOME_TEST="$TEST_ROOT/claude-home"
CLAUDE_PROJECT="$TEST_ROOT/claude-project"
mkdir -p "$CLAUDE_HOME_TEST/.claude" "$CLAUDE_HOME_TEST/.sonmat" "$CLAUDE_PROJECT/.git"
touch "$CLAUDE_HOME_TEST/.claude/CLAUDE.md"
date +%s > "$CLAUDE_HOME_TEST/.sonmat/.last_update_check"
run_hook "$CLAUDE_HOME_TEST" "$CLAUDE_PROJECT" "" >/dev/null
test -f "$CLAUDE_PROJECT/CLAUDE.md"
grep -q '## sonmat' "$CLAUDE_HOME_TEST/.claude/CLAUDE.md"
grep -q 'sonmat:discipline:start' "$CLAUDE_HOME_TEST/.claude/CLAUDE.md"

printf 'Codex support tests passed.\n'
