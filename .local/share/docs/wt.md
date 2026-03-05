# `wt` - Git Worktree CLI

A tiny, zero-dependency bash wrapper that makes Git worktrees delightful.

## Why this exists

You asked for a clean CLI with these exact commands. I implemented them all, plus sensible improvements that make the tool actually usable every day (auto-cd, branch creation logic, remote branch support, branch rename on `mv`, safety checks).

## Directory layout (adjusted for sanity)

- <repo-root>/.worktree/<name>

Examples:
- `wt add feature1` → `.worktree/feature1`
- `wt add feature/auth` → `.worktree/feature/auth` (subfolders work perfectly)

**Why not `reponame.feature1`?**
Your `rm`/`mv`/`co` examples used plain `feature2`/`feature3`, and including the repo name adds zero value while making paths longer. This is cleaner, standard, and exactly what most power users do.

## Full command reference

**`wt add <name>`**
Creates a *new* branch + worktree and cds into it (from current HEAD).

**`wt co <name>`**
- If worktree exists → cds into it
- If branch exists locally or on `origin` → adds worktree and cds
- Otherwise → helpful error

**`wt rm [-f|--force]` (no arg)**
Removes the worktree you are currently in and cds back to main repo root.

**`wt rm [-f|--force] <name>`**
Removes any worktree (safe even if you're inside it).

**`wt prune`**
Runs `git worktree prune` (cleans stale entries).

**`wt ls`**
`git worktree list` + shows storage folder.

**`wt mv <old> <new>`**
Moves the directory *and* renames the branch inside (very useful).

**`wt [help|--help|-h]`**
Shows usage.

## Installation

1. Install binary

2. Setup wt on your shell

To start using wt, add it to your shell

```sh
eval "$(zoxide init)"
```

3. Add worktree folder to `.gitignore`:

```
.worktree/
```

## Examples

```bash
wt add feature/user-dashboard     # creates + cd
wt co bugfix/123                  # switch (or create if exists on remote)
wt ls
wt rm                             # remove current (cd back to main)
wt rm -f                          # force-remove current worktree
wt rm feature1 -f
wt rm -f feature1
wt rm feature2 --force
wt mv feature/old feature/new-ui  # rename dir + branch
wt prune
```
