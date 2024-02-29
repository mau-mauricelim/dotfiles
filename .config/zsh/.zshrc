# Enable Powerlevel10k instant prompt. Should stay close to the top of $HOME/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set up the prompt
autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory autocd

# Characters part of a word. Default is "*?_-.[]~=/&;!#$%^(){}<>"
WORDCHARS="_-.[]~/;!#%^(){}<>"

# Global key bindings mainly for consistency with /etc/inputrc
[ -f $ZDOTDIR/bindkey.zsh ] && source $ZDOTDIR/bindkey.zsh

# Enabling the Zsh Completion System
[ -f $ZDOTDIR/completion.zsh ] && source $ZDOTDIR/completion.zsh
# zoxide - for completions to work, the command must be added after compinit is called
if command -v zoxide >/dev/null; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# Zsh Theme - Powerlevel10k
[ -f $ZDOTDIR/powerlevel10k/powerlevel10k.zsh-theme ] && source $ZDOTDIR/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit $ZDOTDIR/.p10k.zsh
[ ! -f $ZDOTDIR/.p10k.zsh ] || source $ZDOTDIR/.p10k.zsh
# Zsh Auto Suggestions
[ -f $ZDOTDIR/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source $ZDOTDIR/zsh-autosuggestions/zsh-autosuggestions.zsh
# Zsh Syntax Highlighting
# Note the source command must be at the end of $ZDOTDIR/.zshrc
[ -f $ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source $ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
