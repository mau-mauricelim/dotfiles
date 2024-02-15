# Enabling the Zsh Completion System
autoload -Uz compinit
compinit
_comp_options+=(globdots)   # Show hidden files

## Options
setopt GLOB_COMPLETE        # Show autocompletion menu with globs
setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.

## Zstyles
# zstyle pattern
# :completion:<function>:<completer>:<command>:<argument>:<tag>

# Define the completer
zstyle ':completion:*' completer _extensions _complete _approximate
# Enable cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# Completion menu
zstyle ':completion:*' menu select
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' keep-prefix true

# Display format
zstyle ':completion:*'                   format '%F{yellow}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{red}-- %d (errors %e) --%f'
zstyle ':completion:*:*:*:*:warnings'    format '%F{red}-- No matches found --%f'
# Colors for files and directories
eval "$(dircolors -b)"
zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LS_COLORS}
# Only display certain tags for the command cd
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories

# Group results
zstyle ':completion:*' group-name ''
# Modify the order of descriptions displayed
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# See ZSHCOMPWID "completion matching control"
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
