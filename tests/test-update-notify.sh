#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

FAKE_BIN="$TEST_ROOT/bin"
mkdir -p "$FAKE_BIN"
cat > "$FAKE_BIN/curl" <<'CURL'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$CURL_LOG"
if [ "${CURL_FAIL:-false}" = true ]; then
  exit 22
fi
printf '%s\n' "$CURL_RESPONSE"
CURL
chmod +x "$FAKE_BIN/curl"

LOCAL_VER="$(jq -r '.version' "$REPO_ROOT/.claude-plugin/plugin.json")"

run_hook() {
  local name="$1"
  local plugin_data="$2"
  local sonmat_home="$3"
  local home_dir="$TEST_ROOT/$name/home"
  local project_dir="$TEST_ROOT/$name/project"
  local output_file="$TEST_ROOT/$name/output.json"
  mkdir -p "$home_dir/.claude" "$project_dir"
  printf '## sonmat\n' > "$home_dir/.claude/CLAUDE.md"
  (
    cd "$project_dir"
    CURL_LOG="$TEST_ROOT/$name/curl.log" \
      CURL_RESPONSE="${CURL_RESPONSE:-}" \
      CURL_FAIL="${CURL_FAIL:-false}" \
      HOME="$home_dir" \
      PLUGIN_DATA="$plugin_data" \
      CODEX_HOME="$home_dir/.codex" \
      SONMAT_HOME="$sonmat_home" \
      SONMAT_PROJECTS_BASE="$sonmat_home/projects" \
      SONMAT_MEMORY_DIR="$sonmat_home/memory" \
      PATH="$FAKE_BIN:$PATH" \
      bash "$REPO_ROOT/hooks/session-start" > "$output_file"
  )
  jq -e . "$output_file" >/dev/null
  printf '%s\n' "$output_file"
}

assert_no_update_activity() {
  local name="$1"
  local config_value="$2"
  local plugin_data="$3"
  local sonmat_home="$TEST_ROOT/$name/state"
  local timestamp="$sonmat_home/.last_update_check"
  mkdir -p "$sonmat_home"
  if [ "$config_value" != missing ]; then
    printf '%s' "$config_value" > "$sonmat_home/update-notify"
    printf '1234\n' > "$timestamp"
  fi
  CURL_RESPONSE='{"version":"9.9.9"}' run_hook "$name" "$plugin_data" "$sonmat_home" >/dev/null
  test ! -e "$TEST_ROOT/$name/curl.log"
  if [ "$config_value" = missing ]; then
    test ! -e "$timestamp"
  else
    test "$(cat "$timestamp")" = 1234
  fi
  ! grep -q '9.9.9 is available' "$TEST_ROOT/$name/output.json"
}

assert_update_available() {
  local name="$1"
  local plugin_data="$2"
  local manifest_dir="$3"
  local expected_command="$4"
  local sonmat_home="$TEST_ROOT/$name/state"
  mkdir -p "$sonmat_home"
  printf 'on\n' > "$sonmat_home/update-notify"
  CURL_RESPONSE='{"version":"9.9.9"}' run_hook "$name" "$plugin_data" "$sonmat_home" >/dev/null
  grep -q "sonmat ${LOCAL_VER} → 9.9.9 is available" "$TEST_ROOT/$name/output.json"
  grep -q "$manifest_dir/plugin.json" "$TEST_ROOT/$name/curl.log"
  grep -q "$expected_command" "$TEST_ROOT/$name/output.json"
}

baseline_on() {
  assert_update_available claude-on '' .claude-plugin '/plugin update sonmat@sonmat'
  assert_update_available codex-on plugin-data .codex-plugin 'codex plugin marketplace upgrade <source>'
  printf 'baseline ON update-notify tests passed.\n'
}

opt_out_and_edges() {
  for harness in claude codex; do
    plugin_data=''
    if [ "$harness" = codex ]; then
      plugin_data=plugin-data
    fi
    assert_no_update_activity "$harness-missing" missing "$plugin_data"
    assert_no_update_activity "$harness-off" $'off\n' "$plugin_data"
    assert_no_update_activity "$harness-empty" '' "$plugin_data"
    assert_no_update_activity "$harness-invalid" $'yes\n' "$plugin_data"
  done

  injection_home="$TEST_ROOT/injection/state"
  injection_marker="$TEST_ROOT/injection/executed"
  mkdir -p "$injection_home"
  printf 'on\n$(touch %s)\n' "$injection_marker" > "$injection_home/update-notify"
  CURL_RESPONSE='{"version":"9.9.9"}' run_hook injection '' "$injection_home" >/dev/null
  test ! -e "$injection_marker"
  test ! -e "$TEST_ROOT/injection/curl.log"

  override_home="$TEST_ROOT/override/custom-state"
  mkdir -p "$override_home"
  printf 'on\n' > "$override_home/update-notify"
  CURL_RESPONSE='{"version":"9.9.9"}' run_hook override plugin-data "$override_home" >/dev/null
  test -e "$TEST_ROOT/override/curl.log"
  test ! -e "$TEST_ROOT/override/home/.sonmat/.last_update_check"

  same_home="$TEST_ROOT/same/state"
  mkdir -p "$same_home"
  printf 'on\n' > "$same_home/update-notify"
  CURL_RESPONSE="{\"version\":\"$LOCAL_VER\"}" run_hook same '' "$same_home" >/dev/null
  test -e "$TEST_ROOT/same/curl.log"
  ! grep -q 'is available' "$TEST_ROOT/same/output.json"

  recent_home="$TEST_ROOT/recent/state"
  mkdir -p "$recent_home"
  printf 'on\n' > "$recent_home/update-notify"
  date +%s > "$recent_home/.last_update_check"
  CURL_RESPONSE='{"version":"9.9.9"}' run_hook recent '' "$recent_home" >/dev/null
  test ! -e "$TEST_ROOT/recent/curl.log"

  stale_home="$TEST_ROOT/stale/state"
  mkdir -p "$stale_home"
  printf 'on\n' > "$stale_home/update-notify"
  printf '0\n' > "$stale_home/.last_update_check"
  CURL_RESPONSE='{"version":"9.9.9"}' run_hook stale '' "$stale_home" >/dev/null
  test -e "$TEST_ROOT/stale/curl.log"
  test "$(cat "$stale_home/.last_update_check")" -gt 0

  failure_home="$TEST_ROOT/failure/state"
  mkdir -p "$failure_home"
  printf 'on\n' > "$failure_home/update-notify"
  CURL_FAIL=true CURL_RESPONSE='' run_hook failure plugin-data "$failure_home" >/dev/null
  test -e "$TEST_ROOT/failure/curl.log"
  ! grep -q 'is available' "$TEST_ROOT/failure/output.json"

  printf 'update-notify opt-out and edge-case tests passed.\n'
}

case "${TEST_PHASE:-all}" in
  baseline) baseline_on ;;
  off) opt_out_and_edges ;;
  all) baseline_on; opt_out_and_edges ;;
  *) printf 'unknown TEST_PHASE: %s\n' "$TEST_PHASE" >&2; exit 2 ;;
esac
