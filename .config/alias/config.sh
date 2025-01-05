#!/usr/bin/env bash
if command -v nvim >/dev/null; then
    # Don't connect to the X server.
    # Shortens startup time in a terminal, but the window title and clipboard will not be used.
    alias vi="nvim -X"
    export VISUAL=nvim
    export EDITOR=nvim
    export MANPAGER='nvim +Man!'
fi

if command -v eza &> /dev/null; then
    alias ls="eza --group-directories-first --color=auto -a"
    alias tree="eza --tree --group-directories-first --color=auto --git-ignore"
else
    alias ls="ls --group-directories-first -a"
fi

if command -v bat &> /dev/null; then
    # bat in plain style and disables automatic paging
    alias cat="bat -pp"
    alias less="bat --paging=always --style=header,grid"
else
    alias less="less -R --incsearch --use-color"
fi

if command -v lazygit &> /dev/null; then alias lg="lazygit"; fi
# Copy and pasting from Windows to Linux
# ^M is the keyboard equivalent to \r or Ctrl-V + Ctrl-M in Vim
# dos2unix convert or translate the ^M characters
if command -v dos2unix &> /dev/null; then alias d2u="dos2unix"; fi

alias cl="clear"

alias e="exit"
alias d="du -shcL"
alias pd="pushd"
alias xd="popd"
alias ...="cd ../.."
alias ....="cd ../../.."
alias ll="ls -l --icons"
alias lla="ls -lA --icons"
alias la="ls -A"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias rr="rm -r"
alias rrf="rm -rf"
alias tl="tmux ls"
alias ta="tmux attach || tmux"
alias td="tmux detach"
alias pg="ps -ef|grep"
alias k9="kill -9"
alias rg="rg -L --hidden --glob '!.git'"
alias groot='cd $(git rev-parse --show-toplevel)' # I Am Groot!
alias fdh='fd -H'
alias restow='stow .' # use -nv for simulation

# cd with wslpath
if command -v wslpath &> /dev/null; then cdw() { builtin cd -- "`wslpath "$1"`"; }; fi

# Goes up a specified number of directories
up() {
    if [ $# -eq 1 ] && [ $1 -gt 0 ]; then
        local input="../"
        local count="$1"
        printf -v string "%*s" "$count"
        cd $(printf "%s\n" "${string// /$input}")
    fi
}

# Make directory and cd into it
take()   { [ $# -eq 1 ] && mkdir -p "$1" && cd "$1"; }
mkpath() { [ $# -eq 1 ] && mkdir -p "$1"; }
mkfile() { [ $# -eq 1 ] && mkdir -p "$(dirname "$1")" && touch "$1"; }
