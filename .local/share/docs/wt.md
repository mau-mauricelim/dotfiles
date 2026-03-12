# wt — Git Worktree Manager

A minimal, opinionated CLI wrapper around `git worktree` with:

- **Consistent layout** — all worktrees under `<repo>/.worktree/<repo>.<sanitized-ref>`
- **Branch & commit-ish support** — branches checked out normally; tags, SHAs, and any commit-ish create detached-HEAD worktrees automatically
- **Auto-cd** — shell wrapper changes your directory after every `add`, `rm`, `co`, `mv`, and `nuke`
- **Works anywhere** — from main root, inside a linked worktree, or inside `.worktree/` itself
- **Disk-scan resolution** — `rm`, `co`, `mv` find worktrees by scanning disk; immune to remote-URL or directory renames
- **Interactive prompts** — `rm` asks about dirty worktrees and branch deletion; both are overridable with flags
- **Branch lifecycle flags** — `-D` on `rm`/`mv`/`nuke` manages the associated branch
- **Branch sanitization** — `/` and special characters handled gracefully
- **Auto-ignore** — `.worktree/` added to `.git/info/exclude` on first use
- **Coloured output** — consistent palette matching the man page; respects `NO_COLOR` and `TERM=dumb`

---

## Installation

### User-only (recommended)

```sh
# 1. Download and make executable
# export PATH="$PATH:$HOME/.local/bin"
mkdir -p $HOME/.local/bin
curl -fsSL https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.local/bin/wt -o $HOME/.local/bin/wt && chmod +x $HOME/.local/bin/wt

# 2. Install the man page (optional)
# export MANPATH="$HOME/.local/share/man:"
mkdir -p $HOME/.local/share/man/man1
curl -fsSL https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.local/share/man/man1/wt.1 -o $HOME/.local/share/man/man1/wt.1 && chmod +x $HOME/.local/share/man/man1/wt.1
```

### System-wide

```sh
# 1. Download and make executable
sudo curl -fsSL https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.local/bin/wt -o /usr/local/bin/wt && chmod +x /usr/local/bin/wt

# 2. Install the man page (optional)
curl -fsSL https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.local/share/man/man1/wt.1 -o /usr/local/share/man/man1/wt.1 && chmod +x /usr/local/share/man/man1/wt.1

```

### Shell integration

```sh
# 3. Shell integration — add to $HOME/.bashrc or $HOME/.zshrc
echo 'eval "$(wt init)"' >> $HOME/.zshrc
source $HOME/.zshrc
```

> **Why `eval "$(wt init)"`?**
> A subprocess cannot change the parent shell's directory. `wt init` prints
> a small shell function that wraps the binary, strips the internal cd
> directive, and calls `cd` in the current shell. It works identically in
> bash and zsh, and invokes the binary **exactly once** per command.

---

## Worktree Layout

```
my-project/
├── .git/
├── .worktree/                      ← managed by wt
│   ├── my-project.feature-login    ← linked worktree (on branch)
│   ├── my-project.fix-bug-123      ← linked worktree (on branch)
│   ├── my-project.v3.2.2           ← linked worktree (detached HEAD)
│   └── my-project.388d460          ← linked worktree (detached HEAD)
└── src/ ...
```

Branch names and commit-ish refs are sanitized for safe use as directory suffixes:

| Input           | Directory suffix       | State         |
| ---             | ---                    | ---           |
| `feature/login` | `myrepo.feature-login` | on branch     |
| `fix/bug-#123`  | `myrepo.fix-bug-123`   | on branch     |
| `v3.2.2`        | `myrepo.v3.2.2`        | detached HEAD |
| `388d460`       | `myrepo.388d460`       | detached HEAD |
| `release/v2.0`  | `myrepo.release-v2.0`  | detached HEAD |

---

## Commands

### `wt init`

Outputs the shell wrapper function. Source it once via your profile:

```sh
eval "$(wt init)"
```

---

### `wt add <branch|commit-ish>`

Create a new linked worktree and cd into it. Works from **anywhere inside the repo**.

```sh
wt add feature/login    # branch worktree
wt add v3.2.2           # tag  → detached HEAD
wt add 388d460          # SHA  → detached HEAD
wt add HEAD~3           # relative ref → detached HEAD
```

**Resolution order:**

1. **Local branch exists** → checked out on that branch
2. **Valid commit-ish** (tag, full SHA, short SHA, `HEAD~N`, remote ref, …) → `--detach`
3. **Unknown name** → new local branch created

Running `wt add` on an already-existing worktree is **idempotent** — just cds there.

---

### `wt rm [-f] [-D] [name]`

Remove a worktree. Includes two interactive prompts when the relevant flags are not supplied.

```sh
wt rm                 # remove current worktree, cd back to main
wt rm feature/x       # remove by branch name (slash OK)
wt rm v3.2.2          # remove a detached-HEAD worktree
wt rm -f              # force-remove without checking dirty state
wt rm -D feature/x    # remove worktree + delete branch (no prompt)
wt rm -f -D           # force-remove + delete branch, no prompts at all
```

#### Uncommitted-changes prompt

If the worktree has uncommitted changes and `-f` is not passed, `wt` shows the changed files and asks:

```
⚠  myrepo.feature-x has uncommitted changes:
    M  src/foo.rs
   ?? scratch.txt
Remove anyway? [y/N]
```

- **y** — proceeds with `--force` removal
- **n / Enter** — aborts, worktree untouched
- **No terminal (CI / `WT_NO_PROMPT=1`)** — refuses and exits 1; pass `-f` explicitly

#### Branch-deletion prompt

After the worktree is removed, if it was on a local branch and `-D` was not passed, `wt` asks:

```
Delete branch feature/x? [y/N]
```

- **y** — deletes the branch
- **n / Enter** — branch kept (safe default)
- **No terminal (CI / `WT_NO_PROMPT=1`)** — branch kept silently; pass `-D` explicitly

`-D` always skips the prompt. Silently skipped for detached-HEAD worktrees (no branch to delete).

Resolution scans `.worktree/` on disk — immune to prefix changes, repo renames, or remote-URL changes. When removing the worktree you're currently inside, the process CWD moves to the main repo first.

---

### `wt co <n>`

Switch into an existing worktree.

```sh
wt co feature/login
wt co v3.2.2
wt co feature-login    # sanitized name also works
```

---

### `wt ls`

List all worktrees. The active one is highlighted with `▶`. SHA and branch columns are aligned across all rows; the `[main]` badge appears at the end of its row. Detached-HEAD worktrees show `HEAD (detached)` in a distinct colour. Long names are truncated with `…`.

```
  ▶ myrepo.feature-login    a1b2c3d  feature/login
  ◦ myrepo.v3.2.2           f4e5d6c  HEAD (detached)
  ◦ myrepo                  9g8h7i6  main  [main]
```

---

### `wt mv [-D] <from> <to>`

Move/rename a worktree. The destination uses the same prefix as the source.

```sh
wt mv feature/old feature/new       # rename dir only
wt mv -D feature/old feature/new    # rename dir + rename branch
```

If you were inside the old path, you're cd'd to the new one. With `-D`, the associated local branch is renamed via `git branch -m`. Warns and exits 0 for detached-HEAD worktrees.

---

### `wt prune`

Clean up stale metadata for worktrees no longer on disk.

```sh
wt prune
```

---

### `wt nuke [-f] [-D]`

Destroy **all** linked worktrees.

```sh
wt nuke          # prompt, then remove all worktrees (branches kept)
wt nuke -D       # prompt, then remove all + delete branches
wt nuke -f       # no prompt, remove all (branches kept)
wt nuke -f -D    # no prompt, remove all + delete branches
```

Without `-D`, only the worktree directories are removed — **branches are kept**. `-D` opts in to branch deletion.

---

## Full Example Session

```sh
# Setup (once)
echo 'eval "$(wt init)"' >> $HOME/.zshrc && source $HOME/.zshrc

cd $HOME/code/my-project

# Branch worktrees
wt add feature/payments
# → .worktree/my-project.feature-payments (cd'd in)

wt add fix/typo
# → .worktree/my-project.fix-typo (cd'd in)

# Detached-HEAD worktrees
wt add v2.4.1        # inspect a tag
wt add 388d460       # inspect a specific commit

# Navigate
wt ls
wt co feature/payments

# Remove — prompts for branch deletion
wt rm                # remove current, asks "Delete branch?"
wt rm -D fix/typo    # remove + delete branch, no prompt

# Rename worktree dir and branch in one step
wt mv -D feature/payments feature/stripe

# Clean up at end of sprint
wt nuke -f -D        # remove all worktrees + delete their branches
```

---

## Non-Interactive / CI Use

`wt` prompts are designed for interactive terminals and are suppressed in two ways:

| Mechanism               | Effect                                                             |
| ---                     | ---                                                                |
| No controlling terminal | Prompts skipped; dirty `rm` refuses (exit 1), branch kept          |
| `WT_NO_PROMPT=1`        | Same — for scripts that run in a real terminal but want no prompts |

Pass flags explicitly in non-interactive contexts:

```sh
# Fully explicit — no prompts under any conditions
wt rm -f -D feature/done

# Or suppress prompts globally
export WT_NO_PROMPT=1
wt rm -f feature/done       # force-remove, branch kept
wt rm -f -D feature/done    # force-remove + delete branch
```

---

## Colour Palette

`wt` uses a consistent palette matching the man page:

| Role      | Colour       | When you see it                                  |
| ---       | ---          | ---                                              |
| **Teal**  | `\033[1;36m` | command names in help, `→` arrows                |
| **Amber** | `\033[0;33m` | flags (`-f`, `-D`), warnings (`⚠`)               |
| **Plum**  | `\033[0;35m` | commit-ish refs, tags, SHAs, detached HEAD state |
| **Sky**   | `\033[0;34m` | file paths, directory names, non-active branches |
| **Lime**  | `\033[0;32m` | success (`✓`), active worktree marker (`▶`)      |
| **Dim**   | `\033[2m`    | secondary text (SHAs in `ls`, hints, comments)   |
| **Red**   | `\033[0;31m` | errors                                           |

Colours are disabled when `NO_COLOR` is set (any non-empty value) or `TERM=dumb`/unset. See <https://no-color.org>.

---

## Tips

- **No stash needed** — each worktree is a fully independent working directory.
- **Works anywhere** — all commands work from the repo root, inside a linked worktree, or inside the `.worktree/` container directory.
- **Resilient naming** — resolution uses disk scanning, not computed paths. Renaming the repo or changing the remote URL won't break existing worktrees.
- **CI / scripts** — pass `-f -D` explicitly or set `WT_NO_PROMPT=1` to avoid interactive prompts.
- **`.worktree` is auto-ignored** — added to `.git/info/exclude` on first use, so it never appears in `git status`.
- **Detached HEAD safety** — `-D` on `rm`, `mv`, and `nuke` silently skips detached-HEAD worktrees rather than erroring; you'll see a warning instead.

---

## Testing

```sh
bash wt_test.sh    # uses ./wt in the same directory
bash wt_test.sh /path/to/wt
WT_BIN=/usr/local/bin/wt bash wt_test.sh
```

The suite covers **71 tests** across all commands, including regression tests for edge cases and the interactive prompt behaviour. All tests are fully automated — `WT_NO_PROMPT=1` is set internally so no test ever blocks on a prompt.

---

## Requirements

- Git ≥ 2.17 (worktree remove support)
- bash ≥ 3.2 **or** zsh ≥ 4.0
- Standard POSIX utilities: `awk`, `sed`, `grep`

---

## License

MIT
