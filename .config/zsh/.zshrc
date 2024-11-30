# Enable Powerlevel10k instant prompt. Should stay close to the top of $HOME/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
sourceFile "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

setopt histignorealldups sharehistory autocd interactive_comments rmstarsilent

# Characters part of a word. Default is "*?_-.[]~=/&;!#$%^(){}<>"
WORDCHARS="_-.[]~/;!#%^(){}<>"

# Global key bindings mainly for consistency with /etc/inputrc
sourceFile $ZDOTDIR/bindkey.zsh

# Enabling the Zsh Completion System
sourceFile $ZDOTDIR/completion.zsh
# zoxide - for completions to work, the command must be added after compinit is called
if command -v zoxide >/dev/null; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# Zsh Theme - Powerlevel10k
sourceFile $ZDOTDIR/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit $ZDOTDIR/.p10k.zsh
sourceFile $ZDOTDIR/.p10k.zsh
# Zsh Auto Suggestions
sourceFile $ZDOTDIR/zsh-autosuggestions/zsh-autosuggestions.zsh
# Zsh Syntax Highlighting
sourceFile $ZDOTDIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
