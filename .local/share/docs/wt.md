# wt — Git Worktree Manager

TODO: Should `wt rm` also rm branch?

A minimal, opinionated CLI wrapper around `git worktree` with:

- **Consistent layout** — all worktrees under `<repo>/.worktree/<repo>.<branch>`
- **Auto-cd** — shell wrapper changes your directory automatically
- **Works anywhere** — from inside a worktree, from `.worktree/`, from anywhere in the repo
- **Disk-scan resolution** — `rm`, `co`, `mv` find worktrees by scanning disk; immune to remote-URL or directory renames
- **Branch sanitization** — `/` and special characters handled gracefully
- **Auto-ignore** — `.worktree/` added to `.git/info/exclude` on first use
- **Colored output** — respects `NO_COLOR` and `TERM=dumb`

---

## Installation

```sh
# 1. Download and make executable
curl -fsSL https://raw.githubusercontent.com/your-org/wt/main/wt \
  -o /usr/local/bin/wt && chmod +x /usr/local/bin/wt

# 2. Install the man page (optional)
sudo cp wt.1 /usr/local/share/man/man1/wt.1

# 3. Shell integration — add to ~/.bashrc or ~/.zshrc
echo 'eval "$(wt init)"' >> ~/.zshrc
source ~/.zshrc
```

> **Why `eval "$(wt init)"`?**
> A subprocess cannot change the parent shell's directory. `wt init` prints
> a small shell function that wraps the binary and intercepts cd directives.
> It works identically in bash and zsh, and only invokes the binary **once**
> per command.

---

## Worktree Layout

```
my-project/
├── .git/
├── .worktree/                       ← managed by wt
│   ├── my-project.feature-login     ← git linked worktree
│   └── my-project.fix-bug-123       ← git linked worktree
└── src/ ...
```

Branch names are sanitized for safe use as directory components:

| Branch               | Directory suffix         |
|----------------------|--------------------------|
| `feature/login`      | `myrepo.feature-login`   |
| `fix/bug-#123`       | `myrepo.fix-bug-123`     |
| `release/v2.0`       | `myrepo.release-v2.0`    |
| `feature/--double`   | `myrepo.feature-double`  |

---

## Commands

### `wt init`

Outputs the shell function definition. Source it once via your profile:

```sh
eval "$(wt init)"
```

---

### `wt add <branch>`

Create a new linked worktree and cd into it. Works from **anywhere inside the repo** — main root, a linked worktree, or the `.worktree/` container.

```sh
wt add feature/login
# Creates: .worktree/myrepo.feature-login
# cds into: .worktree/myrepo.feature-login
```

- If the branch doesn't exist locally it is **created automatically**.
- Running `wt add` on an already-existing worktree is **idempotent** — just cds there.

---

### `wt rm [-f] [branch]`

Remove a worktree.

```sh
wt rm             # Remove the worktree you're currently in; cd back to root
wt rm feature/x   # Remove a specific worktree by branch name (slash OK)
wt rm -f          # Force-remove even if there are uncommitted changes
```

Resolution is done by scanning `.worktree/` on disk — works regardless of what prefix was used at add-time (safe after repo renames). When removing the worktree you're currently inside, the process CWD is moved to the main repo first, ensuring compatibility with all git versions.

---

### `wt co <branch>`

Switch into an existing worktree.

```sh
wt co feature/login
wt co feature-login   # sanitized name also works
```

---

### `wt ls`

List all worktrees. The current one is highlighted with `▶`. SHA and branch columns are properly aligned across all rows; the `[main]` badge appears at the end of its line. Long names are truncated with `…`.

```
Worktrees

  ▶ myrepo.feature-login    a1b2c3d  feature/login
  ◦ myrepo.fix-bug-123      f4e5d6c  fix/bug-123
  ◦ myrepo                  9g8h7i6  main  [main]
```

---

### `wt mv <from> <to>`

Move/rename a worktree. The destination uses the same name prefix as the source.

```sh
wt mv feature/old feature/new
# Renames .worktree/myrepo.feature-old → .worktree/myrepo.feature-new
# If you were inside the old path, you're cd'd to the new one.
```

---

### `wt prune`

Clean up stale administrative files for worktrees no longer on disk.

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

---

## Full Example Session

```sh
# Setup (once)
echo 'eval "$(wt init)"' >> ~/.zshrc && source ~/.zshrc

cd ~/code/my-project

# Start a new feature
wt add feature/payments
# Now inside: ~/code/my-project/.worktree/my-project.feature-payments

# Open another branch alongside it (from inside a worktree — that's fine)
wt add fix/typo
# Now inside: ~/code/my-project/.worktree/my-project.fix-typo

# See all worktrees
wt ls

# Switch between branches instantly (no stash needed)
wt co feature/payments
wt co fix/typo

# Done with a worktree (from anywhere — even inside it)
wt rm               # removes current, lands back at repo root
wt rm fix/typo      # or remove by name while elsewhere

# Rename something
wt mv feature/payments feature/stripe

# Clean up everything at end of sprint
wt nuke -f
```

---

## Tips

- **No stash needed** — each worktree is a fully independent working directory.
- **Works anywhere** — `wt add`, `wt rm`, `wt ls` etc. all work whether you're in the repo root, inside a linked worktree, or in the `.worktree/` container directory.
- **Resilient naming** — resolution uses disk scanning, not computed paths. Renaming your repo directory or changing the git remote won't break existing worktrees.
- **CI / scripts** — the `wt` binary works without the shell function in non-interactive contexts (no auto-cd, but all git operations still work).
- **The `.worktree` directory** is automatically added to `.git/info/exclude` on first use, so it never shows up in `git status`.

---

## Testing

```sh
bash wt_test.sh [path/to/wt]

# Or with an explicit binary path:
WT_BIN=/usr/local/bin/wt bash wt_test.sh
```

The test suite covers 53 cases across all commands, including regression tests for the bugs fixed in this version.

---

## Requirements

- Git ≥ 2.17 (worktree remove support)
- bash ≥ 3.2 **or** zsh ≥ 4.0
- Standard POSIX utilities: `awk`, `sed`, `grep`

---

## License

MIT
