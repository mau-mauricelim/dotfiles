# Common rc
[ -f $HOME/.commonrc ] && source $HOME/.commonrc

# History configuration
HISTCONTROL=ignoredups:erasedups

# nocaseglob  : Case-insensitive globbing (used in pathname expansion)
# histappend  : Append to the Bash history file, rather than overwriting it
# cdspell     : Autocorrect typos in path names when using `cd`
# autocd      : `**/qux` will enter `./foo/bar/baz/qux`
# globstar    : Recursive globbing, e.g. `echo **/*.txt`
# checkwinsize: Check the window size after each command and, if necessary,
#               update the values of LINES and COLUMNS.
for option in nocaseglob histappend cdspell autocd globstar checkwinsize; do
    shopt -s "$option" 2> /dev/null
done

# Add tab completion for many Bash commands
[ -f /etc/bash_completion ] && source /etc/bash_completion

# Add tab completion for SSH hostnames based on $HOME/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" $HOME/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in
[ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ] && debian_chroot=$(cat /etc/debian_chroot)
# Color prompt
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# If this is an xterm set the title to user@host:dir
PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
    # awk '{ print $1 $2 }'
    complete -W "\'{\ print\ \$\1\,\ \$\2\ }\'" awk
fi

# zoxide
if command -v zoxide >/dev/null; then
    eval "$(zoxide init --cmd cd bash)"
fi