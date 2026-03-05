# wt — Git Worktree Manager

A small, ergonomic CLI wrapper around `git worktree`. It keeps all your
worktrees in a predictable location, handles navigation automatically, and
stays out of your way everywhere else.

## Table of Contents

1. [Why wt?](#why-wt)
2. [Installation](#installation)
3. [Shell Integration (important)](#shell-integration)
4. [Command Reference](#command-reference)
   - [wt add](#wt-add-branch)
   - [wt rm](#wt-rm-branch)
   - [wt prune](#wt-prune)
   - [wt ls](#wt-ls)
   - [wt mv](#wt-mv-from-to)
   - [wt co](#wt-co-branch)
   - [wt install](#wt-install)
   - [wt help](#wt-help)
5. [How Worktrees Are Named](#how-worktrees-are-named)
6. [The cd Problem — How wt Solves It](#the-cd-problem)
7. [Recommended .gitignore](#recommended-gitignore)
8. [Typical Workflows](#typical-workflows)
9. [Design Decisions & Trade-offs](#design-decisions--trade-offs)
10. [Troubleshooting](#troubleshooting)

## Why wt?

`git worktree` lets you have multiple branches checked out simultaneously in
separate directories — no stashing, no branch switching. It is extremely
useful but the raw commands are verbose and easy to mistype.

`wt` adds:

- **Consistent location** — all worktrees live under `<repo>/.worktree/`
- **Auto-navigation** — `cd` into a new or existing worktree automatically
- **Branch creation** — `wt add` creates the branch if it does not exist
- **Safe removal** — detects if you are inside the worktree being deleted and
  moves you out first
- **Pretty listing** — `wt ls` with aligned columns and current-location marker

## Installation

### Manual (recommended)

```sh
# 1. Clone, copy or symlink the two files somewhere on your PATH or anywhere you prefer:
cp $HOME/dotfiles/.local/bin/wt         $HOME/.local/bin/wt
cp $HOME/dotfiles/.local/lib/wt.init.sh $HOME/.local/lib/wt.init.sh

# Make the binary executable
chmod +x $HOME/.local/bin/wt

# 2. Run the installer to add shell integration
wt install

# 3. Reload your shell
source $HOME/.bashrc # or $HOME/.zshrc
```

### Automatic installer

```sh
chmod +x wt
wt install           # writes source line to $HOME/.bashrc and/or $HOME/.zshrc
source $HOME/.bashrc # reload
```

> [!NOTE]
> - `wt install` only adds a `source` line; it does not move any files
> - Make sure `wt` is on your `$PATH` before running it

## Shell Integration

> This is the most important thing to understand about `wt`.

Shell scripts run in a **subshell**. Any `cd` inside a script only affects that
subshell — the moment the script exits, you are back where you started. This
means a plain script can never change your terminal's working directory.

`wt` solves this with a two-layer design:

| Layer          | File         | Role                                                                                             |
| -              | -            | -                                                                                                |
| Binary         | `wt`         | Performs all git operations; emits `__WT_CD__:/path` on stdout when a directory change is needed |
| Shell function | `wt.init.sh` | Wraps the binary; intercepts the `__WT_CD__` token; calls `cd` in your actual shell              |

**Without** the shell function, every command still works **except** navigation
(`wt add`, `wt co`, `wt rm`, `wt mv`, `wt prune` all operate correctly, they
just won't move your terminal).

To install:

```sh
wt install
source $HOME/.bashrc # or $HOME/.zshrc
```

Or manually add to your shell rc:

```sh
source "/path/to/wt.init.sh"
```

## Command Reference

### `wt add <branch>`

Create a new managed worktree for `<branch>` and navigate into it.

```sh
wt add feature/login
wt add bugfix-123
wt add main # worktree for an already-existing branch
```

**What happens:**

1. `mkdir -p <repo-root>/.worktree/`
2. If `<branch>` exists locally → `git worktree add <path> <branch>`
3. If `<branch>` does not exist → `git worktree add -b <branch> <path>`
4. Navigates into the new directory

**Path format:** `<repo-root>/.worktree/<repo-name>.<sanitized-branch>`

**Guards:**
- Fails if the worktree directory already exists (use `wt co` to visit it)
- Fails if the branch is already checked out in another worktree

### `wt rm [branch]`

Remove a managed worktree.

```sh
wt rm               # remove the one you are currently inside
wt rm feature/login # remove a specific one by branch name
```

**What happens:**

1. Resolves which path to remove
2. If you are inside that worktree, navigates to repo root first
3. Runs `git worktree remove <path>`
4. If the tree has uncommitted changes, re-runs with `--force` and warns you

> [!NOTE]
> - `wt rm` does **not** delete the branch itself — only the checked-out directory
> - Delete the branch separately with `git branch -d <branch>`

### `wt prune`

Remove stale git administrative files left behind when worktree directories
are deleted manually.

```sh
wt prune
```

Equivalent to `git worktree prune --verbose`.

If you are currently inside any managed worktree, `wt prune` navigates to the
repo root first (git refuses to prune while inside one of the worktrees).

### `wt ls`

Pretty-print all worktrees.

```sh
wt ls
```

Sample output:

```
 Worktrees — myapp

  Path                                           Commit   Branch
  ─────────────────────────────────────────────  ───────  ──────────────────
  /home/user/projects/myapp                      a1b2c3d  main
▶ /home/user/projects/myapp/.worktree/myapp.fe…  f4e5d6c  feature/login
  /home/user/projects/myapp/.worktree/myapp.bu…  8a9b0c1  bugfix-123

  Managed in .worktree/: 2  |  Repo root: /home/user/projects/myapp
```

The `▶` marker shows the worktree you are currently inside.

### `wt mv <from> <to>`

Move (rename) a managed worktree. Updates both the directory and git's
internal tracking.

```sh
wt mv feature/login auth-v2
wt mv old-experiment new-experiment
```

**What happens:**

1. Resolves `<from>` and `<to>` paths
2. Runs `git worktree move <from-path> <to-path>`
3. If you were inside `<from>`, navigates to the corresponding location in
   `<to>` (preserving any subdirectory you were in)

> [!NOTE]
> - `wt mv` renames the **worktree directory** — it does not rename the git branch
> - To rename the branch as well, run `git branch -m <from> <to>` after

### `wt co <branch>`

Navigate into an existing managed worktree.

```sh
wt co feature/login
wt co bugfix-123
```

`co` is short for "checkout", but unlike `git checkout` it does not switch
branches — it simply changes your working directory to the worktree for
`<branch>`. The branch must already have a worktree (use `wt add` first).

### `wt install`

Append shell integration to `$HOME/.bashrc` and/or `$HOME/.zshrc`.

```sh
wt install
```

Adds a `source` line pointing to `wt.init.sh` (located next to the `wt`
binary). Skips any file that already has it.

After running, reload your shell:

```sh
source $HOME/.bashrc # or $HOME/.zshrc
```

### `wt help`

Print the built-in reference.

```sh
wt help
wt -h
wt --help
```

## How Worktrees Are Named

All worktrees are placed under:

```
<repo-root>/.worktree/<repo-name>.<sanitized-branch>
```

Branch names are **sanitized** for use as directory components:

| Character           | Replacement      |
| -                   | -                |
| `/` (forward slash) | `-` (hyphen)     |
| ` ` (space)         | `_` (underscore) |

Examples:

| Repo         | Branch               | Worktree path                                        |
| -            | -                    | -                                                    |
| `myapp`      | `main`               | `myapp/.worktree/myapp.main`                         |
| `myapp`      | `feature/login`      | `myapp/.worktree/myapp.feature-login`                |
| `myapp`      | `bugfix-123`         | `myapp/.worktree/myapp.bugfix-123`                   |
| `api-server` | `chore/upgrade deps` | `api-server/.worktree/api-server.chore-upgrade_deps` |

The `<repo-name>.` prefix keeps things identifiable when you open
`.worktree/` in a file browser or editor sidebar, especially useful if you
work in a monorepo or have similarly-named branches across repos.

## The cd Problem

> Why do I need a shell function? Why not just a regular script?

When your shell runs a script like `/usr/local/bin/wt`, it forks a new
**child process** (subshell). That child inherits a *copy* of your environment,
including the current directory. Any `cd` inside the script changes the copy
— when the script exits, the child process is destroyed and your shell is
back where it was.

There is no POSIX-portable way for a child process to change its parent's
working directory.

### wt's solution

The `wt` binary communicates the desired directory via a special token on
stdout:

```
__WT_CD__:/path/to/destination
```

The shell wrapper function (`wt.init.sh`) intercepts this:

```bash
wt() {
  # Run binary, capture output
  output=$("$_wt_bin" "$@")

  # Extract cd signal
  cd_path=$(grep "^__WT_CD__:" <<< "$output" | sed 's/^__WT_CD__://')

  # Print everything else normally
  grep -v "^__WT_CD__:" <<< "$output"

  # Actually cd in THIS shell
  [ -n "$cd_path" ] && cd "$cd_path"
}
```

Because the function runs **inside your shell process** (not a subshell), the
`cd` takes effect in your session.

## Recommended .gitignore

Add `.worktree/` to your repo's `.gitignore` so the worktree directories are
not accidentally staged or committed:

```
# .gitignore
.worktree/
```

Git itself already knows about worktrees and will not double-check them out,
but editors (VS Code, IntelliJ, etc.) may try to index them without this entry.

## Typical Workflows

### Start a new feature

```sh
# In main repo:
wt add feature/payment-api
# → creates .worktree/myapp.feature-payment-api
# → navigates there automatically

# Work on the feature...
git add . && git commit -m "feat: payment api skeleton"

# Switch back to main branch:
cd $HOME/projects/myapp
```

### Review a colleague's PR branch

```sh
git fetch origin
wt add origin/review/pr-42     # create worktree from remote branch
# review, run tests ...
wt rm                          # clean up when done
```

### Juggle multiple work streams

```sh
wt ls                           # see what's open
wt co feature/auth              # jump to auth work
# ... do some work ...
wt co bugfix-123                # jump to hotfix
# ... fix the bug ...
wt co feature/auth              # back to auth
```

### Clean up after merging

```sh
# After merging feature/login via PR:
wt rm feature/login             # remove worktree
git branch -d feature/login     # delete the branch
wt prune                        # tidy git bookkeeping
```

## Design Decisions & Trade-offs

| Decision                            | Rationale                                                                                                                                 |
| -                                   | -                                                                                                                                         |
| `.worktree/` directory in repo root | Keeps everything self-contained. One `ls` shows all worktrees for the repo. Consistent across machines.                                   |
| `<repo>.<branch>` naming            | Avoids collisions when multiple repos share branch names. Identifiable at a glance.                                                       |
| Branch sanitization (`/` → `-`)     | Forward slashes in directory names are legal but cause problems in shell tab-completion, some editors, and certain tools.                 |
| `--force` fallback on `wt rm`       | Git refuses to remove worktrees with changes. A warning + force is more useful than a hard failure, since you already asked to remove it. |
| Shell function + binary split       | The binary is portable and testable independently. The shell function is minimal by design.                                               |
| No automatic `.gitignore` edits     | Modifying user files without explicit consent is surprising. The recommendation is documented instead.                                    |
| `wt add` creates branch if missing  | The most common use case is starting new work. Requiring a pre-existing branch adds friction with little benefit.                         |
| `wt rm` does not delete the branch  | Branch lifecycle is separate from worktree lifecycle. Deleting a branch is irreversible; deleting a worktree directory is not.            |

## Troubleshooting

### `wt co` / `wt add` does not change my directory

Shell integration is not active. Run:

```sh
wt install
source $HOME/.bashrc   # or $HOME/.zshrc
```

Then verify the function is loaded:

```sh
type wt    # should say "wt is a function"
```

### `error: fatal: 'refs/heads/...' is already checked out`

Git does not allow the same branch in two worktrees simultaneously. Use a
different branch, or remove the existing worktree first:

```sh
wt rm <that-branch>
wt add <that-branch>
```

### `wt rm` says "No worktree found at: ..."

The path was probably constructed differently from how it was created
(e.g., branch name mismatch). Run `wt ls` to see the exact paths, then
remove manually:

```sh
git worktree list           # find the path
git worktree remove <path>  # remove it
```

### I deleted the directory manually, now git complains

Run `wt prune` (or `git worktree prune`) to tell git the worktree is gone.

### Worktree path looks weird with branch `origin/feature/...`

Remote-tracking branches (`origin/...`) are not local branches and git will
create a detached HEAD worktree. It is usually better to:

```sh
git checkout -b feature/foo origin/feature/foo   # create local branch first
wt add feature/foo
```

Or use `git worktree add --track` directly for remote branches.
