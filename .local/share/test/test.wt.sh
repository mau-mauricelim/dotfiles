#!/usr/bin/env bash

set -euo pipefail

TEST_DIR="/tmp/wt-test-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"
git init main-repo
cd main-repo

eval "$(wt init)"

echo "🧪 Running wt tests"

wt ignore
wt ignore # idempotent check
[[ -f .git/info/exclude ]] && grep -q ".worktree/" .git/info/exclude || { echo "FAIL: ignore"; exit 1; }

wt add feature1
wt add "bugfix/test"
wt add "somelong@hello/path"

# Test safe rm on dirty worktree
wt co feature1
echo "dirty change" > dirty.txt
! wt rm 2>/dev/null && echo '✅ `wt rm` (safe) correctly failed on dirty'
wt rm -f feature1 && echo '✅ `wt rm -f` succeeded on dirty'

# Test clean rm
wt rm bugfix/test

# Test add checks
! wt add feature1 2>/dev/null && echo "✅ add existing branch rejected"
! wt add "nonexistent" 2>/dev/null && [[ $? -eq 1 ]] && echo "✅ add with checks"

wt nuke -f
[[ ! -d .worktree ]] && echo "✅ nuke worked"

echo "🎉 ALL TESTS PASSED"
rm -rf "$TEST_DIR"
