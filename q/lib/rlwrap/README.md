# Unwrapping rlwrap

**Source**: https://github.com/emc211/wp/blob/master/rlwrap/README.md

Sometimes developers have a choice: spend five minutes completing a menial task or spend a little longer streamlining it
for future convenience. This guide helps developers get the most out of rlwrap with q.

## Why rlwrap?

Out of the box, the kdb+/q console does **not** support:
- Editing the current line with arrow keys
- Navigating command history using arrow keys

**rlwrap** is a small utility that adds readline-style editing, history, and search capabilities to interactive programs
such as q.

## Installing rlwrap

If rlwrap is not already installed:
- **macOS**: https://code.kx.com/q/learn/install/macos/#install-rlwrap
- **Linux**: https://code.kx.com/q/learn/install/linux/#install-rlwrap

> [!NOTE]
> - rlwrap is only available for Linux and macOS, not Windows.

Typically, developers install rlwrap, update their q alias, and are content that they no longer need to type entire
expressions left-to-right in a language that is read right-to-left.

However, rlwrap includes several powerful features that are often overlooked. The sections below cover the most useful
ones.

## Features

### Reverse history search (CTRL-r)

#### Problem

A previously executed command needs to be re-run or slightly modified. Repeatedly pressing the up arrow to find it is
slow and frustrating.

#### Solution

rlwrap supports **reverse incremental history search**, similar to Bash.
1. Press **CTRL-r**
2. Start typing part of the command
3. The most recent matching command appears
4. Use the up arrow to cycle through older matches
5. Use the left/right arrows to edit the command, or press Enter to execute it

This allows fast retrieval and reuse of previous commands without scrolling through history line by line.

```q
q)command_1:1+1
q)command_2:{1+x}
q)1+1
2
q)2+2
4
q)//type CTRL-r and start typing desired previously executed command
(reverse-i-search)`comm': command_2:{1+x}
```

![Demonstration of ctrl-r](./docs/ctrlr.gif)

### Clearing the screen (CTRL-l)

#### Problem

The terminal becomes cluttered with output—particularly when presenting, screen sharing, or debugging—and it becomes
difficult to focus on what matters.

#### Solution

Press **CTRL-l**.

This clears the screen in the same way as the `clear` command, without interrupting the q session.

No one ever needs to see that embarrassing `type` error.

![Demonstration of ctrl-l](./docs/ctrll.gif)

### Tab completion with `rlwrap -f`

#### Problem

Remembering q function names can be difficult, especially when:
- Learning kdb+ for the first time
- Joining a new codebase or framework
- Dealing with awkward spellings (e.g. `reciprocal`: `%:`)

Constantly checking https://code.kx.com/q/ref/ quickly becomes disruptive.

#### Solution

rlwrap supports custom tab completion via the `-f` (or `--file`) option.

From `man rlwrap`:
```sh
       -f, --file file
              Split file into words (using the default word-breaking
              characters, or those specified by --break-chars), and add them
              to the completion word list. This option can be given more than
              once, and adds to the default completion list in $RLWRAP_HOME or
              /usr/share/rlwrap/completions.

              Specifying -f . will make rlwrap use the current history file as
              a completion word list.
```

This allows rlwrap to auto-complete words from a specified file, much like tab-completing file paths in a Unix shell.

## Generating a q autocomplete file

A helper script [mkcomp.q](./mkcomp.q) is provided to automatically generate a completion file containing all loaded q functions.

```
$ q mkcomp.q SAVEFILE
```

```q
q).mkcomp.list[`.fzf`.mkcomp`customVar;()]
".fzf"
".fzf.fzfObject"
...
".mkcomp.list"
".mkcomp.listAll"
".mkcomp.write"
"customVar"

q).mkcomp.list[`.fzf`.mkcomp`customVar;`.mkcomp.listAll`.mkcomp.write]
".fzf"
".fzf.fzfObject"
...
".mkcomp.list"
"customVar"

q).mkcomp.write[`:path/to/rlwrap_completion] .mkcomp.list[`.fzf`.mkcomp`customVar;`.mkcomp.listAll`.mkcomp.write];
2026.01.15D08:10:21.218572910 [INFO]: Rlwrap auto complete file written to: path/to/rlwrap_completion
```

## Using the completion file

Start a new q session with rlwrap using the `-f` option and reference the file just created:
```sh
rlwrap -f ~/rlwrap_completion q
```

Now:
- Press **Tab** to auto-complete function names
- Press **Tab twice** to list all available completions

### Example output

```
q)
Display all 376 possibilities? (y or n)
.Q.    .Q.bv   .Q.gc   .h.xt   and    hsym   parse   trim
...
```

Typing a prefix and pressing Tab twice shows matching options:

```
q)re<Tab><Tab>
read0       read1       reciprocal  reval       reverse
```

Selecting and executing the function:

```
q)reciprocal
%:
```

![Demonstration of rlwrap -f](./docs/demoFile.gif)

You never have to spell *reciprocal* again.
