#!/usr/bin/env bash
# wt_test.sh — Comprehensive test suite for the wt Git Worktree Manager
# Usage:  bash wt_test.sh [path/to/wt]
#         WT_BIN=/usr/local/bin/wt bash wt_test.sh
set -euo pipefail

WT_BIN="${1:-${WT_BIN:-$(cd "$(dirname "$0")" && pwd)/wt}}"

# ── Colors ────────────────────────────────────────────────────────────────────
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; NC=$'\033[0m'

# ── State ─────────────────────────────────────────────────────────────────────
PASS=0; FAIL=0; SKIP=0; FAILED_TESTS=()
TMPDIR_ROOT=""

# ── Fixtures ──────────────────────────────────────────────────────────────────
cleanup() { [[ -n "${TMPDIR_ROOT:-}" ]] && rm -rf "$TMPDIR_ROOT"; return 0; }
trap cleanup EXIT

make_repo() {
  # make_repo <dir> — initialise a git repo with one commit and no remote.
  local dir="$1"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" config user.email "test@test.com"
  git -C "$dir" config user.name  "Test"
  touch "$dir/README.md"
  git -C "$dir" add .
  git -C "$dir" commit -q -m "init"
}

# ── Helpers ───────────────────────────────────────────────────────────────────

# Run the wt binary with TERM set; strip hidden cd directives from stdout.
WT() { TERM=xterm command "$WT_BIN" "$@" 2>/dev/null | grep -v '^__WT_CD__:'; }

# Run the wt binary and extract only the cd directive path.
WT_cd() {
  TERM=xterm command "$WT_BIN" "$@" 2>/dev/null \
    | grep '^__WT_CD__:' | tail -1 | sed 's/^__WT_CD__://' || true
}

# Run the wt binary and return its exit code (suppress output).
WT_exit() { local rc=0; TERM=xterm command "$WT_BIN" "$@" &>/dev/null || rc=$?; echo "$rc"; }

# ── Assertions ────────────────────────────────────────────────────────────────

assert_eq() {
  local label="$1" got="$2" want="$3"
  [[ "$got" == "$want" ]] && return 0
  printf '    %bFAIL%b  %s\n' "$RED" "$NC" "$label"
  printf '      got:  [%b%s%b]\n' "$DIM" "$got" "$NC"
  printf '      want: [%b%s%b]\n' "$DIM" "$want" "$NC"
  return 1
}

assert_contains() {
  local label="$1" haystack="$2" needle="$3"
  printf '%s' "$haystack" | grep -qF "$needle" && return 0
  printf '    %bFAIL%b  %s\n'              "$RED" "$NC" "$label"
  printf '      needle: [%b%s%b]\n'        "$DIM" "$needle" "$NC"
  printf '      in:     [%b%s%b]\n'        "$DIM" "$haystack" "$NC"
  return 1
}

assert_not_contains() {
  local label="$1" haystack="$2" needle="$3"
  ! printf '%s' "$haystack" | grep -qF "$needle" && return 0
  printf '    %bFAIL%b  %s — needle should NOT appear: [%b%s%b]\n' \
    "$RED" "$NC" "$label" "$DIM" "$needle" "$NC"
  return 1
}

assert_dir_exists()  {
  local label="$1" dir="$2"
  [[ -d "$dir" ]] && return 0
  printf '    %bFAIL%b  %s: directory not found: %s\n' "$RED" "$NC" "$label" "$dir"
  return 1
}

assert_dir_missing() {
  local label="$1" dir="$2"
  [[ ! -d "$dir" ]] && return 0
  printf '    %bFAIL%b  %s: directory should not exist: %s\n' "$RED" "$NC" "$label" "$dir"
  return 1
}

assert_exit_ok()   {
  local label="$1"; shift
  local rc; rc=$(WT_exit "$@")
  [[ "$rc" -eq 0 ]] && return 0
  printf '    %bFAIL%b  %s: expected exit 0, got %s\n' "$RED" "$NC" "$label" "$rc"
  return 1
}

assert_exit_fail() {
  local label="$1"; shift
  local rc; rc=$(WT_exit "$@")
  [[ "$rc" -ne 0 ]] && return 0
  printf '    %bFAIL%b  %s: expected non-zero exit\n' "$RED" "$NC" "$label"
  return 1
}

# ── Test runner ───────────────────────────────────────────────────────────────

run_test() {
  local name="$1" fn="$2"
  printf '  %b•%b %s … ' "$CYAN" "$NC" "$name"

  TMPDIR_ROOT=$(mktemp -d)
  local repo="$TMPDIR_ROOT/repo"
  make_repo "$repo"
  export _REPO="$repo"

  local rc=0
  ( cd "$repo" && "$fn" ) || rc=$?

  rm -rf "$TMPDIR_ROOT"; TMPDIR_ROOT=""

  if [[ $rc -eq 0 ]]; then
    printf '%bpass%b\n' "$GREEN" "$NC"; (( PASS++ )) || true
  else
    printf '%bFAIL%b\n' "$RED"   "$NC"; (( FAIL++ )) || true
    FAILED_TESTS+=("$name")
  fi
}

section() { printf '\n%b%s%b\n' "$BOLD" "$1" "$NC"; }

# ═════════════════════════════════════════════════════════════════════════════
# TEST CASES
# ═════════════════════════════════════════════════════════════════════════════

# ── Sanitize ──────────────────────────────────────────────────────────────────

test_sanitize_slash() {
  WT add "feature/login" >/dev/null
  assert_dir_exists "creates repo.feature-login" \
    "$_REPO/.worktree/$(basename "$_REPO").feature-login"
}

test_sanitize_special_chars() {
  git checkout -qb "fix/bug@1.0"
  git checkout -q main 2>/dev/null || git checkout -q master
  WT add "fix/bug@1.0" >/dev/null
  assert_dir_exists "sanitizes @ in branch name" \
    "$_REPO/.worktree/$(basename "$_REPO").fix-bug-1.0"
}

test_sanitize_consecutive_dashes() {
  # feature/--double  →  feature-double  (consecutive dashes collapsed)
  WT add "feature/--double" >/dev/null
  assert_dir_exists "collapses consecutive dashes" \
    "$_REPO/.worktree/$(basename "$_REPO").feature-double"
}

# ── wt add ────────────────────────────────────────────────────────────────────

test_add_new_branch() {
  local out; out=$(WT add feature/new-thing)
  assert_contains "output mentions worktree name" "$out" ".feature-new-thing"
  assert_dir_exists "worktree dir created" \
    "$_REPO/.worktree/$(basename "$_REPO").feature-new-thing"
}

test_add_existing_branch() {
  git checkout -qb existing-branch
  git checkout -q main 2>/dev/null || git checkout -q master
  WT add existing-branch >/dev/null
  local wt_path="$_REPO/.worktree/$(basename "$_REPO").existing-branch"
  assert_dir_exists "worktree exists" "$wt_path"
  local head_branch
  head_branch=$(git -C "$wt_path" branch --show-current 2>/dev/null || true)
  assert_eq "branch is existing-branch" "$head_branch" "existing-branch"
}

test_add_idempotent_no_nest() {
  WT add feature/idem >/dev/null
  local out; out=$(WT add feature/idem)
  assert_contains "says already at" "$out" "already at"
  assert_dir_missing "no nested .worktree inside worktree" \
    "$_REPO/.worktree/$(basename "$_REPO").feature-idem/.worktree"
}

test_add_idempotent_no_warning() {
  # Idempotent add should NOT say "already exists" (old confusing message).
  WT add feature/idem2 >/dev/null
  local out; out=$(WT add feature/idem2)
  assert_not_contains "no 'already exists' warning" "$out" "already exists"
}

test_add_emits_cd() {
  local target; target=$(WT_cd add feature/cd-test)
  local expected="$_REPO/.worktree/$(basename "$_REPO").feature-cd-test"
  assert_eq "cd directive points to new worktree" "$target" "$expected"
}

test_add_idempotent_emits_cd() {
  WT add feature/cd-idem >/dev/null
  local expected="$_REPO/.worktree/$(basename "$_REPO").feature-cd-idem"
  local target; target=$(WT_cd add feature/cd-idem)
  assert_eq "idempotent add still emits cd" "$target" "$expected"
}

test_add_auto_exclude() {
  WT add feature/excl >/dev/null
  assert_contains ".worktree in git exclude" \
    "$(cat "$_REPO/.git/info/exclude")" "/.worktree"
}

# Bug: add should work from anywhere inside the repo (including .worktree/ container).
test_add_from_worktree_container() {
  WT add feature/first >/dev/null
  mkdir -p "$_REPO/.worktree"
  # Simulate being in the .worktree container dir (not a linked worktree).
  local repo_name; repo_name=$(basename "$_REPO")
  local wt_path="$_REPO/.worktree/${repo_name}.feature-from-container"
  local cd_target
  cd_target=$(cd "$_REPO/.worktree" && WT_cd add feature/from-container)
  assert_dir_exists "worktree created from .worktree container" "$wt_path"
  assert_eq "cd emitted correctly" "$cd_target" "$wt_path"
}

# Bug: add from inside a linked worktree should also work.
test_add_from_inside_linked_worktree() {
  WT add feature/base >/dev/null
  local repo_name; repo_name=$(basename "$_REPO")
  local base_path="$_REPO/.worktree/${repo_name}.feature-base"
  local new_path="$_REPO/.worktree/${repo_name}.feature-from-linked"
  local cd_target
  cd_target=$(cd "$base_path" && WT_cd add feature/from-linked)
  assert_dir_exists "worktree created from inside linked worktree" "$new_path"
  assert_eq "cd emitted to new worktree" "$cd_target" "$new_path"
}

# ── wt rm ─────────────────────────────────────────────────────────────────────

test_rm_by_branch_name() {
  WT add feature/to-remove >/dev/null
  local wt_path="$_REPO/.worktree/$(basename "$_REPO").feature-to-remove"
  WT rm feature/to-remove >/dev/null
  assert_dir_missing "worktree removed" "$wt_path"
}

test_rm_by_short_name() {
  # User passes bare name without the slash prefix.
  WT add feature/short-rm >/dev/null
  WT rm feature/short-rm >/dev/null
  assert_dir_missing "removed by branch name" \
    "$_REPO/.worktree/$(basename "$_REPO").feature-short-rm"
}

# Bug: wt rm <name> where <name> resolves via disk scan, not repo_name().
test_rm_resolves_by_scan() {
  # Create worktrees.  repo_name() uses dirname = repo but pretend we're
  # resolving later (same session, same repo_name, still exercises scan path).
  WT add feature/scan-rm >/dev/null
  local wt_path="$_REPO/.worktree/$(basename "$_REPO").feature-scan-rm"
  assert_dir_exists "setup: worktree exists" "$wt_path"
  # Remove using the branch name with slash — resolve_wt_path must scan.
  WT rm "feature/scan-rm" >/dev/null
  assert_dir_missing "scan-based rm succeeded" "$wt_path"
}

test_rm_from_within() {
  WT add feature/inner >/dev/null
  local wt_path="$_REPO/.worktree/$(basename "$_REPO").feature-inner"

  # Capture ALL output (stdout+stderr) so git errors are visible on test failure.
  local full_out cd_target
  full_out=$(cd "$wt_path" && TERM=xterm command "$WT_BIN" rm 2>&1) || true
  cd_target=$(printf '%s\n' "$full_out" | grep '^__WT_CD__:' | tail -1 | sed 's/^__WT_CD__://') || true

  # If removal failed, print wt/git output so the failure is diagnosable.
  if [[ -d "$wt_path" ]]; then
    printf '    wt output (rm failed):\n' >&2
    printf '%s\n' "$full_out" | sed 's/^/      /' >&2
  fi

  assert_eq "cd back to main repo" "$cd_target" "$_REPO"
  assert_dir_missing "worktree removed" "$wt_path"
}

test_rm_nonexistent_fails() {
  assert_exit_fail "rm nonexistent exits non-zero" rm no-such-worktree
}

test_rm_from_main_without_name_fails() {
  assert_exit_fail "rm without name from main fails" rm
}

# ── wt ls ─────────────────────────────────────────────────────────────────────

test_ls_shows_main() {
  local out; out=$(WT ls)
  assert_contains "ls shows [main]" "$out" "[main]"
}

test_ls_shows_linked_worktrees() {
  WT add feature/alpha >/dev/null
  WT add feature/beta  >/dev/null
  local out; out=$(WT ls)
  local repo_name; repo_name=$(basename "$_REPO")
  assert_contains "alpha in ls" "$out" "${repo_name}.feature-alpha"
  assert_contains "beta in ls"  "$out" "${repo_name}.feature-beta"
}

# Bug: [main] badge must not shift the SHA column.
test_ls_sha_column_aligned() {
  WT add feature/a >/dev/null
  WT add feature/b >/dev/null
  local out; out=$(TERM=xterm command "$WT_BIN" ls 2>/dev/null | grep -v '^__WT_CD__:')
  # Strip ANSI codes for analysis.
  local plain
  plain=$(printf '%s' "$out" | sed 's/\x1b\[[0-9;]*m//g')
  # Find the sha column position on the main line and a worktree line.
  # The sha (7 hex chars) should start at the same offset on every data line.
  local sha_positions
  sha_positions=$(printf '%s\n' "$plain" \
    | grep -E '^\s+[▶◦]' \
    | awk '{
        for(i=1;i<=NF;i++){
          if($i ~ /^[0-9a-f]{7}$/) { print index($0,$i); break }
        }
      }' | sort -u | wc -l | tr -d ' ')
  # All rows should have their SHA at the same offset → exactly 1 unique position.
  assert_eq "sha column aligned across all rows" "$sha_positions" "1"
}

# Bug: long names must not overflow the layout.
test_ls_long_name_truncated() {
  local long; long=$(printf 'x%.0s' {1..60})
  WT add "$long" >/dev/null 2>&1 || true
  local out; out=$(WT ls)
  assert_contains "ls with long name still shows [main]" "$out" "[main]"
  assert_contains "long name shows ellipsis" "$out" "..."
}

test_ls_no_color_env() {
  local out
  out=$(NO_COLOR=1 TERM=xterm command "$WT_BIN" ls 2>/dev/null | grep -v '^__WT_CD__:')
  assert_contains "ls works with NO_COLOR" "$out" "[main]"
  ! printf '%s' "$out" | grep -qP '\033\[' \
    || { printf '    FAIL  ANSI codes present with NO_COLOR=1\n'; return 1; }
}

# ── wt co ─────────────────────────────────────────────────────────────────────

test_co_existing() {
  WT add feature/checkout-me >/dev/null
  local expected="$_REPO/.worktree/$(basename "$_REPO").feature-checkout-me"
  local cd_target; cd_target=$(WT_cd co feature/checkout-me)
  assert_eq "co emits correct cd path" "$cd_target" "$expected"
}

test_co_nonexistent_fails() {
  assert_exit_fail "co nonexistent fails" co no-such-branch
}

# ── wt mv ─────────────────────────────────────────────────────────────────────

test_mv_basic() {
  WT add feature/old-name >/dev/null
  local repo_name; repo_name=$(basename "$_REPO")
  local old_path="$_REPO/.worktree/${repo_name}.feature-old-name"
  local new_path="$_REPO/.worktree/${repo_name}.feature-new-name"
  WT mv feature/old-name feature/new-name >/dev/null
  assert_dir_missing "old path gone"    "$old_path"
  assert_dir_exists  "new path present" "$new_path"
}

test_mv_from_within_emits_cd() {
  WT add feature/mv-from >/dev/null
  local repo_name; repo_name=$(basename "$_REPO")
  local from_path="$_REPO/.worktree/${repo_name}.feature-mv-from"
  local new_path="$_REPO/.worktree/${repo_name}.feature-mv-to"
  local cd_target
  cd_target=$(cd "$from_path" && WT_cd mv feature/mv-from feature/mv-to)
  assert_eq "mv from within emits new path" "$cd_target" "$new_path"
}

# Bug: mv where source uses a different prefix from current repo_name().
test_mv_resolves_by_scan() {
  # Create worktree (prefix = basename of repo dir).
  WT add feature/payments >/dev/null
  local repo_name; repo_name=$(basename "$_REPO")
  local old_path="$_REPO/.worktree/${repo_name}.feature-payments"
  local new_path="$_REPO/.worktree/${repo_name}.feature-stripe"
  assert_dir_exists "setup: worktree exists" "$old_path"
  # mv should resolve via disk scan — using branch name with slash.
  WT mv "feature/payments" "feature/stripe" >/dev/null
  assert_dir_missing "old path gone"    "$old_path"
  assert_dir_exists  "new path present" "$new_path"
}

# Bug: mv keeps the SAME prefix as the source (doesn't switch to repo_name()).
test_mv_preserves_prefix() {
  WT add myfeature >/dev/null
  local repo_name; repo_name=$(basename "$_REPO")
  # Both old and new should share the same prefix.
  local old_path="$_REPO/.worktree/${repo_name}.myfeature"
  local new_path="$_REPO/.worktree/${repo_name}.myfeature-v2"
  WT mv myfeature myfeature-v2 >/dev/null
  assert_dir_missing "old path gone"    "$old_path"
  assert_dir_exists  "new path present" "$new_path"
}

test_mv_nonexistent_fails() {
  assert_exit_fail "mv nonexistent source fails" mv no-such ghost
}

# ── wt prune ─────────────────────────────────────────────────────────────────

test_prune_exits_ok() {
  assert_exit_ok "prune exits 0" prune
}

test_prune_output() {
  local out; out=$(WT prune)
  assert_contains "prune output has 'pruning'" "$out" "pruning"
}

# ── wt nuke ──────────────────────────────────────────────────────────────────

test_nuke_force_removes_all() {
  WT add feature/nuke1 >/dev/null
  WT add feature/nuke2 >/dev/null
  local repo_name; repo_name=$(basename "$_REPO")
  WT nuke -f >/dev/null
  assert_dir_missing "nuke1 gone" "$_REPO/.worktree/${repo_name}.feature-nuke1"
  assert_dir_missing "nuke2 gone" "$_REPO/.worktree/${repo_name}.feature-nuke2"
}

test_nuke_deletes_branches() {
  WT add feature/delbranch >/dev/null
  WT nuke -f >/dev/null
  local branches; branches=$(git branch --list "feature/delbranch")
  assert_eq "branch deleted after nuke" "$branches" ""
}

test_nuke_no_worktrees_message() {
  local out; out=$(WT nuke -f)
  assert_contains "message when nothing to nuke" "$out" "no linked worktrees"
}

test_nuke_from_within_emits_cd() {
  WT add feature/was-here >/dev/null
  local repo_name; repo_name=$(basename "$_REPO")
  local wt_path="$_REPO/.worktree/${repo_name}.feature-was-here"
  local cd_target
  cd_target=$(cd "$wt_path" && WT_cd nuke -f)
  assert_eq "nuke from worktree cds back to main" "$cd_target" "$_REPO"
}

# ── wt init ───────────────────────────────────────────────────────────────────

test_init_outputs_function() {
  local out; out=$(TERM=xterm command "$WT_BIN" init)
  assert_contains "init outputs wt() function"   "$out" "wt()"
  assert_contains "init uses command wt"          "$out" "command wt"
  assert_contains "init handles cd directive"     "$out" "__WT_CD__"
}

# Bug: init must contain exactly ONE invocation of command wt.
test_init_single_invocation() {
  local out; out=$(TERM=xterm command "$WT_BIN" init)
  local count
  count=$(printf '%s\n' "$out" | grep -c 'command wt')
  assert_eq "init has exactly one 'command wt'" "$count" "1"
}

test_init_valid_bash_syntax() {
  local out; out=$(TERM=xterm command "$WT_BIN" init)
  bash -c "$out" 2>&1
  assert_eq "init function parses in bash" "ok" "ok"
}

test_init_valid_zsh_syntax() {
  if ! command -v zsh &>/dev/null; then
    printf '(zsh not available, skipping) '; return 0
  fi
  local out; out=$(TERM=xterm command "$WT_BIN" init)
  zsh -c "$out" 2>&1
  assert_eq "init function parses in zsh" "ok" "ok"
}

# ── Shell wrapper add-only-runs-once ──────────────────────────────────────────

test_wrapper_add_runs_once() {
  # Using the shell wrapper: add should create exactly one worktree dir,
  # not report "already exists" because it ran twice.
  local repo_name; repo_name=$(basename "$_REPO")
  local wt_path="$_REPO/.worktree/${repo_name}.feature-once"

  # Simulate the shell wrapper's single-invocation pattern.
  local out
  out=$(TERM=xterm command "$WT_BIN" add feature/once)
  # Extract cd
  local cd_target
  cd_target=$(printf '%s\n' "$out" | grep '^__WT_CD__:' | tail -1 | sed 's/^__WT_CD__://')
  # Filter output
  local visible
  visible=$(printf '%s\n' "$out" | grep -v '^__WT_CD__:' || true)

  assert_dir_exists "worktree created" "$wt_path"
  assert_not_contains "no 'already exists' in output" "$visible" "already exists"
  assert_eq "cd directive points to new dir" "$cd_target" "$wt_path"
}

test_wrapper_add_idempotent_no_duplicate_warning() {
  # Running add twice via the wrapper should give "already at" once, not twice.
  local repo_name; repo_name=$(basename "$_REPO")
  TERM=xterm command "$WT_BIN" add feature/tw >/dev/null 2>/dev/null

  local out
  out=$(TERM=xterm command "$WT_BIN" add feature/tw 2>/dev/null | grep -v '^__WT_CD__:' || true)
  # Should say "already at", not "already exists"
  assert_not_contains "no old 'already exists' message" "$out" "already exists"
  assert_contains     "says 'already at'"               "$out" "already at"
}

# ── Colors ────────────────────────────────────────────────────────────────────

test_colors_present_with_term() {
  local out
  out=$(TERM=xterm command "$WT_BIN" ls 2>/dev/null | grep -v '^__WT_CD__:')
  printf '%s' "$out" | grep -qP '\033\[' \
    || { printf '    FAIL  no ANSI codes with TERM=xterm\n'; return 1; }
}

test_colors_absent_with_no_color() {
  local out
  out=$(NO_COLOR=1 TERM=xterm command "$WT_BIN" ls 2>/dev/null | grep -v '^__WT_CD__:')
  ! printf '%s' "$out" | grep -qP '\033\[' \
    || { printf '    FAIL  ANSI codes present despite NO_COLOR=1\n'; return 1; }
}

test_colors_absent_with_dumb_term() {
  local out
  out=$(TERM=dumb command "$WT_BIN" ls 2>/dev/null | grep -v '^__WT_CD__:')
  ! printf '%s' "$out" | grep -qP '\033\[' \
    || { printf '    FAIL  ANSI codes present with TERM=dumb\n'; return 1; }
}

# ── Error handling ────────────────────────────────────────────────────────────

test_outside_git_repo() {
  local tmp; tmp=$(mktemp -d)
  local rc=0
  (cd "$tmp" && TERM=xterm command "$WT_BIN" ls 2>/dev/null) || rc=$?
  rm -rf "$tmp"
  [[ $rc -ne 0 ]] && return 0
  printf '    FAIL  should fail outside git repo\n'; return 1
}

test_unknown_command_fails()     { assert_exit_fail "unknown command"     totally-invalid-cmd; }
test_add_no_args_fails()         { assert_exit_fail "add without args"    add; }
test_co_no_args_fails()          { assert_exit_fail "co without args"     co; }
test_mv_missing_args_fails()     { assert_exit_fail "mv with one arg"     mv only-one; }

# ── Version / help ────────────────────────────────────────────────────────────

test_help_exits_ok()    { assert_exit_ok "help exits 0" help; }
test_version_exits_ok() { assert_exit_ok "version exits 0" version; }

test_version_has_number() {
  local out; out=$(TERM=xterm command "$WT_BIN" version)
  printf '%s' "$out" | grep -qE '[0-9]+\.[0-9]+' \
    || { printf '    FAIL  no version number in output\n'; return 1; }
}

# ═════════════════════════════════════════════════════════════════════════════
# RUN
# ═════════════════════════════════════════════════════════════════════════════

if [[ ! -x "$WT_BIN" ]]; then
  printf '%berror:%b %s not found or not executable\n\n' "$RED" "$NC" "$WT_BIN"
  printf '%bUsage:%b  %s [path/to/wt]\n' "$BOLD" "$NC" "$0"
  printf '         WT_BIN=/usr/local/bin/wt %s\n\n' "$0"
  exit 1
fi

printf '\n%bwt test suite%b  (%b%s%b)\n' "$BOLD" "$NC" "$DIM" "$WT_BIN" "$NC"

section "Sanitize"
run_test "slash in branch name"                       test_sanitize_slash
run_test "special chars (@) in branch name"           test_sanitize_special_chars
run_test "consecutive dashes collapsed"               test_sanitize_consecutive_dashes

section "wt add"
run_test "add new branch"                             test_add_new_branch
run_test "add existing branch (no -b flag)"           test_add_existing_branch
run_test "add idempotent — no nesting"                test_add_idempotent_no_nest
run_test "add idempotent — no 'already exists' msg"   test_add_idempotent_no_warning
run_test "add emits cd directive"                     test_add_emits_cd
run_test "add idempotent — still emits cd"            test_add_idempotent_emits_cd
run_test "add updates .git/info/exclude"              test_add_auto_exclude
run_test "add from .worktree container dir"           test_add_from_worktree_container
run_test "add from inside linked worktree"            test_add_from_inside_linked_worktree

section "wt rm"
run_test "rm by branch name (with slash)"             test_rm_by_branch_name
run_test "rm by short name"                           test_rm_by_short_name
run_test "rm resolves via disk scan"                  test_rm_resolves_by_scan
run_test "rm from within worktree"                    test_rm_from_within
run_test "rm nonexistent exits non-zero"              test_rm_nonexistent_fails
run_test "rm from main without name fails"            test_rm_from_main_without_name_fails

section "wt ls"
run_test "ls shows [main]"                            test_ls_shows_main
run_test "ls shows linked worktrees"                  test_ls_shows_linked_worktrees
run_test "ls sha column aligned (main badge at end)"  test_ls_sha_column_aligned
run_test "ls truncates very long names"               test_ls_long_name_truncated
run_test "ls respects NO_COLOR"                       test_ls_no_color_env

section "wt co"
run_test "co existing worktree"                       test_co_existing
run_test "co nonexistent exits non-zero"              test_co_nonexistent_fails

section "wt mv"
run_test "mv renames worktree dir"                    test_mv_basic
run_test "mv from within emits cd"                    test_mv_from_within_emits_cd
run_test "mv resolves source via disk scan"           test_mv_resolves_by_scan
run_test "mv preserves source prefix"                 test_mv_preserves_prefix
run_test "mv nonexistent source fails"                test_mv_nonexistent_fails

section "wt prune"
run_test "prune exits 0"                              test_prune_exits_ok
run_test "prune has expected output"                  test_prune_output

section "wt nuke"
run_test "nuke -f removes all worktrees"              test_nuke_force_removes_all
run_test "nuke -f deletes branches"                   test_nuke_deletes_branches
run_test "nuke with nothing to remove"                test_nuke_no_worktrees_message
run_test "nuke from worktree cds to main"             test_nuke_from_within_emits_cd

section "wt init"
run_test "init outputs shell function"                test_init_outputs_function
run_test "init contains exactly one invocation"       test_init_single_invocation
run_test "init function valid bash syntax"            test_init_valid_bash_syntax
run_test "init function valid zsh syntax"             test_init_valid_zsh_syntax

section "Shell wrapper correctness"
run_test "add runs exactly once (no double-invoke)"   test_wrapper_add_runs_once
run_test "idempotent add — no duplicate warning"      test_wrapper_add_idempotent_no_duplicate_warning

section "Colors"
run_test "colors present with TERM=xterm"             test_colors_present_with_term
run_test "colors absent with NO_COLOR=1"              test_colors_absent_with_no_color
run_test "colors absent with TERM=dumb"               test_colors_absent_with_dumb_term

section "Error handling"
run_test "fails outside git repo"                     test_outside_git_repo
run_test "unknown command fails"                      test_unknown_command_fails
run_test "add without args fails"                     test_add_no_args_fails
run_test "co without args fails"                      test_co_no_args_fails
run_test "mv with one arg fails"                      test_mv_missing_args_fails

section "Version / Help"
run_test "help exits 0"                               test_help_exits_ok
run_test "version exits 0"                            test_version_exits_ok
run_test "version contains number"                    test_version_has_number

# ── Summary ───────────────────────────────────────────────────────────────────
total=$(( PASS + FAIL + SKIP ))
printf '\n%b────────────────────────────────────────%b\n' "$DIM" "$NC"
printf ' %b%d passed%b  ' "$GREEN" "$PASS" "$NC"
[[ $FAIL -gt 0 ]] && printf '%b%d failed%b  ' "$RED" "$FAIL" "$NC"
[[ $SKIP -gt 0 ]] && printf '%b%d skipped%b  ' "$YELLOW" "$SKIP" "$NC"
printf 'of %d total\n' "$total"
printf '%b────────────────────────────────────────%b\n\n' "$DIM" "$NC"

if [[ $FAIL -gt 0 ]]; then
  printf '%bFailed tests:%b\n' "$RED" "$NC"
  for t in "${FAILED_TESTS[@]}"; do printf '  • %s\n' "$t"; done
  printf '\n'; exit 1
fi
exit 0
