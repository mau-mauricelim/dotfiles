#!/usr/bin/env bash
source "$HOME/.bashrc"

latestAndInstalledVersion() {
    echo "$1"
    echo "Latest   : $2"
    echo "Installed: $3"
    echo ""
}

latestRelease() { curl -sL https://github.com/"$1"/releases/latest|grep 'breadcrumb-item-selected'|grep -oP '(?<=tag/).+(?=" data)'; }
# No releases
latestTag() { curl -s https://github.com/"$1"/tags|grep 'Link--primary Link'|head -1|sed 's/.*class="Link--primary Link">\([^<]*\).*/\1/'; }

latestAndInstalledVersion zsh \
    "$(curl -s https://zsh.sourceforge.io/FAQ/zshfaq01.html|grep 'latest production version'|cut -d' ' -f2)" \
    "$(zsh --version)"

latestAndInstalledVersion git \
    "$(latestTag git/git)" \
    "$(git --version)"

latestAndInstalledVersion stow \
    "$(latestTag aspiers/stow)" \
    "$(stow --version)"

latestAndInstalledVersion rg \
    "$(latestRelease BurntSushi/ripgrep)" \
    "$(rg --version|grep ripgrep)"

latestAndInstalledVersion fd \
    "$(latestRelease sharkdp/fd)" \
    "$(fd --version)"

latestAndInstalledVersion bat \
    "$(latestRelease sharkdp/bat)" \
    "$(bat --version)"

latestAndInstalledVersion hyperfine \
    "$(latestRelease sharkdp/hyperfine)" \
    "$(hyperfine --version)"

latestAndInstalledVersion tmux \
    "$(latestRelease tmux/tmux)" \
    "$(tmux -V)"

latestAndInstalledVersion eza \
    "$(latestRelease eza-community/eza)" \
    "$(eza -v|grep ^v)"

latestAndInstalledVersion lazygit \
    "$(latestRelease jesseduffield/lazygit)" \
    "$(lazygit --version|sed 's/.*, version=\([^ ]*\),.*$/\1/'|head -1)"

latestAndInstalledVersion delta \
    "$(latestRelease dandavison/delta)" \
    "$(delta --version|head -1)"

latestAndInstalledVersion zoxide \
    "$(latestRelease ajeetdsouza/zoxide)" \
    "$(zoxide --version)"

latestAndInstalledVersion nvim \
    "$(latestRelease neovim/neovim)" \
    "$(nvim --version|grep NVIM)"

latestAndInstalledVersion fzf \
    "$(latestRelease junegunn/fzf)" \
    "$(fzf --version)"

latestAndInstalledVersion npm \
    "$(latestRelease npm/cli)" \
    "$(npm --version)"

latestAndInstalledVersion yazi \
    "$(latestRelease sxyazi/yazi)" \
    "$(yazi --version)"

latestAndInstalledVersion jq \
    "$(latestRelease jqlang/jq)" \
    "$(jq --version)"

latestAndInstalledVersion exiftool \
    "$(latestTag exiftool/exiftool)" \
    "$(exiftool -ver)"

latestAndInstalledVersion copyparty \
    "$(latestTag 9001/copyparty)" \
    "$(copyparty --version 2>&1 | grep -vE '(\[SFX\]|^$)')"

latestAndInstalledVersion jdupes \
    "$(curl -sL https://codeberg.org/jbruchon/jdupes/releases/latest|grep tagName|head -1|grep -oP '(?<=: ").+(?=")')" \
    "$(jdupes -v | head -1)"
