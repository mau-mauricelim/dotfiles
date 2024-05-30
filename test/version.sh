#!/usr/bin/env bash
latestAndInstalledVersion() {
    echo "$1"
    echo "Latest   : $2"
    echo "Installed: $3"
    echo ""
}

latestAndInstalledVersion zsh \
    "$(curl -s 'https://zsh.sourceforge.io/FAQ/zshfaq01.html' | grep 'latest production version' | cut -d' ' -f2)" \
    "$(zsh --version)"

latestAndInstalledVersion rg \
    "$(curl -s 'https://api.github.com/repos/BurntSushi/ripgrep/releases/latest' | grep tag_name | cut -d '"' -f4)" \
    "$(rg --version | grep ripgrep)"

latestAndInstalledVersion fd \
    "$(curl -s 'https://api.github.com/repos/sharkdp/fd/releases/latest' | grep tag_name | cut -d '"' -f4)" \
    "$(fd --version)"

latestAndInstalledVersion bat \
    "$(curl -s 'https://api.github.com/repos/sharkdp/bat/releases/latest' | grep tag_name | cut -d '"' -f4)" \
    "$(bat --version)"

latestAndInstalledVersion git \
    "$(curl -s 'https://api.github.com/repos/git/git/tags' | grep name | head -1 | cut -d '"' -f4)" \
    "$(git --version)"

latestAndInstalledVersion stow \
    "$(curl -s 'https://api.github.com/repos/aspiers/stow/tags' | grep name | head -1 | cut -d '"' -f4)" \
    "$(stow --version)"

latestAndInstalledVersion tmux \
    "$(curl -s 'https://api.github.com/repos/tmux/tmux/releases/latest' | grep tag_name | cut -d '"' -f4)" \
    "$(tmux -V)"

latestAndInstalledVersion eza \
    "$(curl -s 'https://api.github.com/repos/eza-community/eza/releases/latest' | grep tag_name | cut -d '"' -f4)" \
    "$(eza -v | grep ^v)"

latestAndInstalledVersion lazygit \
    "$(curl -s 'https://api.github.com/repos/jesseduffield/lazygit/releases/latest' | grep tag_name | cut -d '"' -f4)" \
    "$(lazygit --version | sed 's/.*, version=\([^ ]*\),.*$/\1/')"

latestAndInstalledVersion delta \
    "$(curl -s 'https://api.github.com/repos/dandavison/delta/releases/latest' | grep tag_name | cut -d '"' -f4)" \
    "$(delta --version)"

latestAndInstalledVersion zoxide \
    "$(curl -s 'https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest' | grep tag_name | cut -d '"' -f4)" \
    "$(zoxide --version)"

latestAndInstalledVersion nvim \
    "$(curl -s 'https://api.github.com/repos/nvim/nvim/releases/latest' | grep tag_name | cut -d '"' -f4)" \
    "$(nvim --version | grep NVIM)"

latestAndInstalledVersion fzf \
    "$(curl -s 'https://api.github.com/repos/junegunn/fzf/releases/latest' | grep tag_name | cut -d '"' -f4)" \
    "$(fzf --version)"
