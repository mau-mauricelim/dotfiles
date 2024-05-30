#!/usr/bin/env bash
latestAndInstalledVersion() {
    echo "$1"
    echo "Latest   : $2"
    echo "Installed: $3"
    echo ""
}

latestAndInstalledVersion zsh \
    "$(curl -s https://zsh.sourceforge.io/FAQ/zshfaq01.html|grep 'latest production version'|cut -d' ' -f2)" \
    "$(zsh --version)"

latestAndInstalledVersion git \
    "$(curl -s https://github.com/git/git/tags|grep 'Link--primary Link'|head -1|sed 's/.*class="Link--primary Link">\([^<]*\).*/\1/')" \
    "$(git --version)"

latestAndInstalledVersion stow \
    "$(curl -s https://github.com/aspiers/stow/tags|grep 'Link--primary Link'|head -1|sed 's/.*class="Link--primary Link">\([^<]*\).*/\1/')" \
    "$(stow --version)"

latestAndInstalledVersion rg \
    "$(curl -sL https://github.com/BurntSushi/ripgrep/releases/latest|grep 'breadcrumb-item-selected'|rev|cut -d'>' -f1|rev|xargs)" \
    "$(rg --version|grep ripgrep)"

latestAndInstalledVersion fd \
    "$(curl -sL https://github.com/sharkdp/fd/releases/latest|grep 'breadcrumb-item-selected'|rev|cut -d'>' -f1|rev|xargs)" \
    "$(fd --version)"

latestAndInstalledVersion bat \
    "$(curl -sL https://github.com/sharkdp/bat/releases/latest|grep 'breadcrumb-item-selected'|rev|cut -d'>' -f1|rev|xargs)" \
    "$(bat --version)"

latestAndInstalledVersion tmux \
    "$(curl -sL https://github.com/tmux/tmux/releases/latest|grep 'breadcrumb-item-selected'|rev|cut -d'>' -f1|rev|xargs)" \
    "$(tmux -V)"

latestAndInstalledVersion eza \
    "$(curl -sL https://github.com/eza-community/eza/releases/latest|grep 'breadcrumb-item-selected'|rev|cut -d'>' -f1|rev|xargs)" \
    "$(eza -v|grep ^v)"

latestAndInstalledVersion lazygit \
    "$(curl -sL https://github.com/jesseduffield/lazygit/releases/latest|grep 'breadcrumb-item-selected'|rev|cut -d'>' -f1|rev|xargs)" \
    "$(lazygit --version|sed 's/.*, version=\([^ ]*\),.*$/\1/'|head -1)"

latestAndInstalledVersion delta \
    "$(curl -sL https://github.com/dandavison/delta/releases/latest|grep 'breadcrumb-item-selected'|rev|cut -d'>' -f1|rev|xargs)" \
    "$(delta --version|head -1)"

latestAndInstalledVersion zoxide \
    "$(curl -sL https://github.com/ajeetdsouza/zoxide/releases/latest|grep 'breadcrumb-item-selected'|rev|cut -d'>' -f1|rev|xargs)" \
    "$(zoxide --version)"

latestAndInstalledVersion nvim \
    "$(curl -sL https://github.com/nvim/nvim/releases/latest|grep 'breadcrumb-item-selected'|rev|cut -d'>' -f1|rev|xargs)" \
    "$(nvim --version|grep NVIM)"

latestAndInstalledVersion fzf \
    "$(curl -sL https://github.com/junegunn/fzf/releases/latest|grep 'breadcrumb-item-selected'|rev|cut -d'>' -f1|rev|xargs)" \
    "$(fzf --version)"
