#!/usr/bin/env bash
if command -v nvim >/dev/null; then
    # Don't connect to the X server.
    # Shortens startup time in a terminal, but the window title and clipboard will not be used.
    alias vi="nvim -X"
    # <leader>sg
    alias vg="nvim -X -c 'lua Snacks.picker.grep({ hidden = true })'"
    # <leader>sf
    alias vf="nvim -X -c 'lua Snacks.picker.files({ hidden = true })'"
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

if command -v hyperfine &> /dev/null; then alias hf="hyperfine"; fi
# NOTE: `+`   : makes the view larger
#       `<CR>`: on a commit shows the files changed
#       `<CR>`: on a file shows the diff
if command -v lazygit &> /dev/null; then alias lg="lazygit"; fi
# Copy and pasting from Windows to Linux
# ^M is the keyboard equivalent to \r or Ctrl-V + Ctrl-M in Vim
# dos2unix convert or translate the ^M characters
if command -v dos2unix &> /dev/null; then alias d2u="dos2unix"; fi

alias ....="cd ../../.."
alias ...="cd ../.."
alias cdl="cd -"
alias cl="clear"
alias cpr="cp -r"
alias d="du -shcL"
alias e="exit"
alias egrep="egrep --color=auto"
alias fdh='fd -H'
alias fgrep="fgrep --color=auto"
alias grep="grep --color=auto"
alias groot='cd $(git rev-parse --show-toplevel)' # I Am Groot!
alias k9="kill -9"
alias la="ls -A"
alias ldr="ls -d {.,}*/"
alias ll="ls -l --icons"
alias lla="ls -lA --icons"
alias pd="pushd"
alias pg="ps -ef|grep"
alias restow='stow .' # use -nv for simulation
alias rg="rg -L --hidden --glob '!.git'"
alias rr="rm -r"
alias rrf="rm -rf"
alias s="ssh"
alias ta="tmux attach || tmux"
alias td="tmux detach"
alias tl="tmux ls"
alias x="xargs"
alias xd="popd"
if command -v rg &> /dev/null; then alias g="rg"; else alias g="grep"; fi

# cd with wslpath
if command -v wslpath &> /dev/null; then cdw() { builtin cd -- "`wslpath "$1"`"; }; fi

# Goes up a specified number of directories
up() {
    if [ $# -eq 1 ] && [ "$1" -gt 0 ]; then
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
# Git clone and cd into it
clone()  {
    if [ "$#" -eq 1 ]; then
        git clone "$1" && cd "$(basename "$1" .git)"
    else
        git clone "$1" "$2" && cd "$2"
    fi
}
