# wt — Git Worktree Manager

A minimal, opinionated CLI wrapper around `git worktree` with:

- **Consistent layout** — all worktrees under `<repo>/.worktree/<repo>.<branch>`
- **Auto-cd** — shell wrapper changes your directory automatically
- **Branch sanitization** — `/` and other odd characters handled gracefully
- **Auto-ignore** — `.worktree/` added to `.git/info/exclude` on first use
- **Colored output**

---

## Installation

```sh
# 1. Download and make executable
curl -fsSL https://raw.githubusercontent.com/your-org/wt/main/wt \
  -o /usr/local/bin/wt && chmod +x /usr/local/bin/wt

# 2. Install the man page (optional)
sudo cp wt.1 /usr/local/share/man/man1/wt.1

# 3. Install shell integration — add to ~/.bashrc or ~/.zshrc
echo 'eval "$(wt init)"' >> ~/.zshrc
source ~/.zshrc
```

> **Why `eval "$(wt init)"`?**  
> A subprocess cannot change the parent shell's directory. `wt init` prints
> a small shell function that wraps the binary and intercepts cd directives.
> It works identically in bash and zsh.

---

## Worktree Layout

```
my-project/
├── .git/
├── .worktree/                    ← managed by wt
│   ├── my-project.feature-login  ← git linked worktree
│   └── my-project.fix-bug-123    ← git linked worktree
└── src/ ...
```

Branch names are sanitized for safe use as directory components:

| Branch               | Directory suffix          |
|----------------------|---------------------------|
| `feature/login`      | `myrepo.feature-login`    |
| `fix/bug-#123`       | `myrepo.fix-bug--123`     |
| `release/v2.0`       | `myrepo.release-v2.0`     |

---

## Commands

### `wt init`

Outputs the shell function definition. Source it once via your profile:

```sh
eval "$(wt init)"
```

---

### `wt add <branch>`

Create a new linked worktree and cd into it.

```sh
wt add feature/login
# Creates: .worktree/myrepo.feature-login
# cds into: .worktree/myrepo.feature-login
```

- If the branch doesn't exist locally it is **created automatically**.
- Running `wt add` on an already-existing worktree is **idempotent** — it
  just cds into the existing path instead of nesting another directory.

---

### `wt rm [-f] [branch]`

Remove a worktree.

```sh
wt rm             # Remove the worktree you're currently in; cd back to root
wt rm feature/x   # Remove a specific worktree by branch name
wt rm -f          # Force-remove even if there are uncommitted changes
```

---

### `wt co <branch>`

Switch into an existing worktree.

```sh
wt co feature/login
```

If the worktree doesn't exist yet, use `wt add` first.

---

### `wt ls`

List all worktrees. The current one is highlighted with `▶`.

```
Worktrees

  ▶ myrepo.feature-login          a1b2c3d  feature/login
  ◦ myrepo.fix-bug-123            f4e5d6c  fix/bug-123
  ◦ myrepo            [main]      9g8h7i6  main
```

---

### `wt mv <from> <to>`

Move/rename a worktree.

> [!NOTE]
> Does not rename branch

```sh
wt mv feature/old feature/new
# Renames .worktree/myrepo.feature-old → .worktree/myrepo.feature-new
# If you were inside the old path, you're cd'd to the new path automatically.
```

---

### `wt prune`

Clean up stale administrative files for worktrees that no longer exist on disk.

```sh
wt prune
```

---

### `wt nuke [-f]`

Destroy **all** linked worktrees and **delete** their local branches.

```sh
wt nuke       # Prompts for confirmation
wt nuke -f    # No prompt
```

This is destructive. Make sure your branches are pushed or otherwise safe
before running it.

---

## Full Example Session

```sh
# Setup (once)
echo 'eval "$(wt init)"' >> ~/.zshrc && source ~/.zshrc

cd ~/code/my-project

# Start a new feature
wt add feature/payments
# Now inside: ~/code/my-project/.worktree/my-project.feature-payments

# Open another branch alongside it
wt add fix/typo
# Now inside: ~/code/my-project/.worktree/my-project.fix-typo

# See all worktrees
wt ls

# Jump back to main
wt co main   # or just: cd ~/code/my-project

# Switch between branches instantly (no stash needed!)
wt co feature/payments
wt co fix/typo

# Done with a worktree
wt rm               # removes current, lands back at repo root

# Rename something
wt mv feature/payments feature/stripe

# Clean up everything at end of sprint
wt nuke -f
```

---

## Tips

- **No stash needed** — each worktree is a fully independent working directory.
  Switch instantly between branches without committing or stashing anything.

- **CI / scripts** — the `wt` binary works without the shell function in
  non-interactive contexts (no auto-cd, but all git operations still work).

- **The `.worktree` directory** is automatically added to
  `.git/info/exclude` on first use, so it never shows up in `git status`.

---

## Requirements

- Git ≥ 2.5 (worktree support)
- bash ≥ 3.2 **or** zsh ≥ 4.0
- Standard POSIX utilities: `awk`, `sed`, `grep`

---

## License

MIT
