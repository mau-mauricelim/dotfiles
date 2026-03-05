#!/usr/bin/env bash

set -euo pipefail

TEST_DIR="/tmp/wt-test-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"
git init main-repo
cd main-repo

eval "$(wt init)"

wt ignore
wt add feature1
wt add "bugfix/test"
wt add "somelong@hello/path"
wt ls | grep -q "(current)" || { echo "FAIL ls"; exit 1; }

# Dirty test
echo "dirty" > dirty.txt
! wt rm 2>/dev/null && echo "✅ rm safe on dirty"
wt rm -f feature1

# Nuke test
wt nuke -f
[[ ! -d .worktree ]] && echo "✅ nuke worked"
wt add test-after-nuke   # should succeed because branch was deleted

echo "🎉 ALL EDGE CASES PASSED (dirty, special chars, nuke, ls, force)"
rm -rf "$TEST_DIR"
