# Retrieve emacs bindings in the form of bindkey commands
local emacs_binding=$(bindkey -L)

# https://thevaluable.dev/zsh-install-configure-mouseless - Zsh With Vim Flavors
# Use vi mode
bindkey -v
# Makes the switch between modes quicker
export KEYTIMEOUT=10
# Apply emacs bindings to vi
eval $emacs_binding

# Exit insert mode with `kj`
bindkey -M viins 'kj' vi-cmd-mode

# Change cursor shape when switching between modes
cursor_mode() {
    cursor_block='\e[2 q'
    cursor_beam='\e[6 q'
    function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]] ||
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
        fi
    }
    zle-line-init() {
        echo -ne $cursor_beam
    }
    zle -N zle-keymap-select
    zle -N zle-line-init
}
cursor_mode

# Adding Text Objects
# Examples:
#  - va)  - [V]isually select [A]round [)]paren
#  - ci'  - [C]hange [I]nside [']quote
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
  bindkey -M $km -- '-' vi-up-line-or-history
  for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
    bindkey -M $km $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $km $c select-bracketed
  done
done

# Add/delete/replace surroundings (brackets, quotes, etc.)
# Examples:
# - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
# - sd'   - [S]urround [D]elete [']quotes
# - sr)'  - [S]urround [R]eplace [)] [']
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd sr change-surround
bindkey -M vicmd sd delete-surround
bindkey -M vicmd sa add-surround
bindkey -M visual sa add-surround
