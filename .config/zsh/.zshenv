# Common rc
[ -f $HOME/.commonrc ] && source $HOME/.commonrc

# Zsh Environment Variables
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# History configuration
export HISTFILE="$ZDOTDIR/.zsh_history" # History filepath
export SAVEHIST=10000                   # Maximum events in history file
