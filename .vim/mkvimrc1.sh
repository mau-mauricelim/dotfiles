#!/usr/bin/env bash
# Make single vimrc file for portability (except filetype.vim, indent and syntax files)

SCRIPT_DIR="$(dirname "$0")"
vimrc1="$SCRIPT_DIR/vimrc1"

echo '" Single vimrc file for portability (except filetype.vim, indent and syntax files)' > "$vimrc1"

banner() {
    msg="\"| $1 |"
    edge=$(echo "$msg" | sed 's/./-/g; s/^../"+/; s/.$/+/')
    echo
    echo "$edge"
    echo "$msg"
    echo "$edge"
    echo
}

write() {
    banner "$1"
    cat "$SCRIPT_DIR/config/$1.vim"
}

# NOTE: Order is important here
for config in vim-plug options keymaps autocmds functions plugins; do
    echo "Writing $config to $vimrc1"
    write "$config" >> "$vimrc1"
done
