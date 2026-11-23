#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

run_hook() {
  local home_dir="$1"
  local project_dir="$2"
  local plugin_data="$3"
  local plugin_root="${4:-$REPO_ROOT}"
  (
    cd "$project_dir"
    HOME="$home_dir" \
      PLUGIN_DATA="$plugin_data" \
      CODEX_HOME="$home_dir/.codex" \
      SONMAT_HOME="$home_dir/.sonmat" \
      SONMAT_PROJECTS_BASE="$home_dir/state/projects" \
      SONMAT_MEMORY_DIR="$home_dir/state/memory" \
      bash "$plugin_root/hooks/session-start"
  )
}

# Codex: engage discipline, report missing agents, and never mutate instruction files.
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
test ! -e "$CODEX_PROJECT/AGENTS.md"

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

# Claude Code: create AGENTS.md as the project-rule source and an importing adapter.
CLAUDE_HOME_TEST="$TEST_ROOT/claude-home"
CLAUDE_PROJECT="$TEST_ROOT/claude-project"
mkdir -p "$CLAUDE_HOME_TEST/.claude" "$CLAUDE_HOME_TEST/.sonmat" "$CLAUDE_PROJECT/.git"
touch "$CLAUDE_HOME_TEST/.claude/CLAUDE.md"
date +%s > "$CLAUDE_HOME_TEST/.sonmat/.last_update_check"
run_hook "$CLAUDE_HOME_TEST" "$CLAUDE_PROJECT" "" >/dev/null
test -f "$CLAUDE_PROJECT/AGENTS.md"
grep -q '## Project Rules' "$CLAUDE_PROJECT/AGENTS.md"
test -f "$CLAUDE_PROJECT/CLAUDE.md"
grep -qx '@AGENTS.md' "$CLAUDE_PROJECT/CLAUDE.md"
grep -q '## sonmat' "$CLAUDE_HOME_TEST/.claude/CLAUDE.md"
grep -q 'sonmat:discipline:start' "$CLAUDE_HOME_TEST/.claude/CLAUDE.md"

# An existing core import already supplies the discipline.
IMPORT_HOME="$TEST_ROOT/import-home"
IMPORT_PROJECT="$TEST_ROOT/import-project"
mkdir -p "$IMPORT_HOME/.claude" "$IMPORT_HOME/.sonmat" "$IMPORT_PROJECT/.git"
printf '@~/control-tower/bedrock/sonmat/discipline/core.md\n' > "$IMPORT_HOME/.claude/CLAUDE.md"
date +%s > "$IMPORT_HOME/.sonmat/.last_update_check"
run_hook "$IMPORT_HOME" "$IMPORT_PROJECT" "" >/dev/null
if grep -q 'sonmat:discipline' "$IMPORT_HOME/.claude/CLAUDE.md"; then
  printf 'discipline block added despite existing core import\n' >&2
  exit 1
fi

# Existing CLAUDE.md is not silently rewritten or migrated.
LEGACY_PROJECT="$TEST_ROOT/legacy-project"
mkdir -p "$LEGACY_PROJECT/.git"
printf 'legacy project rules\n' > "$LEGACY_PROJECT/CLAUDE.md"
LEGACY_OUTPUT="$(run_hook "$CLAUDE_HOME_TEST" "$LEGACY_PROJECT" "")"
grep -q 'migration needs a reviewed' <<< "$LEGACY_OUTPUT"
test ! -e "$LEGACY_PROJECT/AGENTS.md"
grep -qx 'legacy project rules' "$LEGACY_PROJECT/CLAUDE.md"

# Parse actual hook output and recover path text, including every control byte
# allowed in shell strings (NUL cannot occur in a Unix path or Bash variable).
# uv/Python is a test-only JSON parser; the hook still requires only Bash.
JSON_CASES="$TEST_ROOT/json-cases"
mkdir -p "$JSON_CASES"
CONTROL_BYTES=""
for ((code = 1; code < 32; code++)); do
  printf -v control_byte '\\%03o' "$code"
  printf -v control_byte '%b' "$control_byte"
  CONTROL_BYTES+="$control_byte"
done
PATH_CASES=(plain '공백 경로' 'quote"-backslash\-literal\n' $'line\nbreak' "controls-${CONTROL_BYTES}-end")
for case_index in "${!PATH_CASES[@]}"; do
  case_dir="$JSON_CASES/$case_index"
  plugin_root="$case_dir/${PATH_CASES[$case_index]}/plugin"
  home_dir="$case_dir/${PATH_CASES[$case_index]}/home"
  project_dir="$case_dir/project"
  mkdir -p "$plugin_root/hooks" "$home_dir/.claude" "$project_dir/.git" "$project_dir/.claude/sonmat"
  cp "$REPO_ROOT/hooks/session-start" "$plugin_root/hooks/session-start"
  printf '%s' "$plugin_root" > "$case_dir/plugin-root.txt"
  printf '%s' "$home_dir" > "$case_dir/home-dir.txt"
  printf '## sonmat\n<!-- sonmat:discipline -->\n' > "$home_dir/.claude/CLAUDE.md"
  printf 'preserve\n' > "$project_dir/.claude/sonmat/note.md"
  run_hook "$home_dir" "$project_dir" "$case_dir/plugin-data" "$plugin_root" > "$case_dir/codex.json"
  run_hook "$home_dir" "$project_dir" "" "$plugin_root" > "$case_dir/claude.json"
done
uv run --no-project python - "$JSON_CASES" <<'PY'
import json
import sys
from pathlib import Path

for case_dir in sorted(Path(sys.argv[1]).iterdir()):
    plugin = (case_dir / "plugin-root.txt").read_bytes().decode()
    home = (case_dir / "home-dir.txt").read_bytes().decode()
    project = case_dir / "project"
    expected = {
        "codex": (
            f"sonmat: read {plugin}/discipline/core.md and the matching hints in "
            f"{plugin}/discipline/hints.md, then apply them as the premise of this session. "
            "If your permission instructions say danger-full-access with approval never, also read "
            f"{plugin}/discipline/codex-full-access.md and apply it in full. sonmat Codex agents are not installed "
            "(sonmat_worker sonmat_witness sonmat_scribe). Review and run: "
            f'bash "{plugin}/scripts/install-codex-agents.sh"'
        ),
        "claude": (
            "AGENTS.md auto-created as the project-rule source; CLAUDE.md now imports it. "
            f"sonmat scribe migrated: .claude/sonmat → {home}/state/projects/{str(project).replace('/', '-')}"
        ),
    }
    for harness, context in expected.items():
        output = json.loads((case_dir / f"{harness}.json").read_text())
        assert output == {"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": context}}, (
            case_dir.name, harness, "hook context did not round-trip"
        )
print("Hook JSON round-trip passed: five path cases, both harness branches.")
PY

printf 'Codex support tests passed.\n'
