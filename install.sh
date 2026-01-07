#!/usr/bin/env bash
# Usage: bash install.sh [full]
INSTALL_TYPE="${1:-min}"         # Defaults to minimal install
INSTALL_TYPE="${INSTALL_TYPE,,}" # Lowercase

echo_with_date() { echo "$(date) [INFO]: $1"; }

main() {
    source /etc/os-release
    case $ID in
        alpine|ubuntu)
            run_install $ID
            ;;
        *)
            echo_with_date "$ID is not supported"
            ;;
    esac
}

run_install() { echo_with_date "Running $1 installer"; cd "$HOME" || exit 1; "${1}_install"; }

set_url_and_version() {
    echo_with_date "Setting URL and VERSION for $1"
    repo_name=$(echo "$1" | cut -d"/" -f2)
    repo_name=${repo_name^^} # Uppercase
    repo_name=${repo_name//-/_} # Convert `-` to `_`
    # Sets release url e.g. RIPGREP_URL=https://github.com/BurntSushi/ripgrep/releases/latest/download
    eval "${repo_name}_URL"="https://github.com/$1/releases/latest/download"
    latest_tag=$(curl -sSfL "https://api.github.com/repos/$1/releases/latest" | grep tag_name | cut -d '"' -f4)
    # Strip v (first charcter) from tag
    if [ "$2" = "true" ]; then latest_tag="${latest_tag:1}"; fi
    # Sets release version e.g. RIPGREP_VERSION=14.1.0
    eval "${repo_name}_VERSION"="$latest_tag"
}

set_all_url_and_version() {
    set_url_and_version "jqlang/jq"
    set_url_and_version "sxyazi/yazi"
    set_url_and_version "neovim/neovim"
    set_url_and_version "9001/copyparty"
    set_url_and_version "dandavison/delta"
    set_url_and_version "BurntSushi/ripgrep"
    set_url_and_version "scarvalhojr/aoc-cli"
    set_url_and_version "sharkdp/fd" true
    set_url_and_version "sharkdp/bat" true
    set_url_and_version "sharkdp/hyperfine" true
    set_url_and_version "eza-community/eza" true
    set_url_and_version "jesseduffield/lazygit" true
}

common_root_install() {
    echo_with_date "Running common root install"
    # Manual install of man pages for release binaries
    sudo mkdir -p /usr/local/share/man/man1
    # Set release url and version
    set_all_url_and_version
    # Install MUSL ripgrep from source
    [ -n "$RIPGREP_VERSION" ] && \
        curl -sSfL "$RIPGREP_URL/ripgrep-$RIPGREP_VERSION-x86_64-unknown-linux-musl.tar.gz" \
            | tar xz "ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/rg" "ripgrep-$RIPGREP_VERSION-x86_64-unknown-linux-musl/doc/rg.1" --strip-components=1 && \
        sudo install rg /usr/local/bin && sudo mv doc/rg.1 /usr/local/share/man/man1 && rm -r rg doc
    # Install MUSL aoc-cli from source
    [ -n "$AOC_CLI_VERSION" ] && \
        curl -sSfL "$AOC_CLI_URL/aoc-cli-$AOC_CLI_VERSION-x86_64-unknown-linux-musl.tar.gz" \
            | tar xz "aoc-cli-${AOC_CLI_VERSION}-x86_64-unknown-linux-musl/aoc" --strip-components=1 && \
        sudo install aoc /usr/local/bin && rm aoc
    # Install LINUX lazygit from source
    [ -n "$LAZYGIT_VERSION" ] && \
        curl -sSfL "$LAZYGIT_URL/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" | tar xz lazygit && \
        sudo install lazygit /usr/local/bin && rm lazygit
    # Install LINUX jq from source
    [ -n "$JQ_VERSION" ] && \
        curl -sSfLo jq "$JQ_URL/jq-linux-amd64" && \
        curl -sSfL "$JQ_URL/$JQ_VERSION.tar.gz" | tar xz "$JQ_VERSION/jq.1" --strip-components=1 && \
        sudo install jq /usr/local/bin && sudo mv jq.1 /usr/local/share/man/man1 && rm jq
    # Install zoxide from source
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh |\
        sudo bash -s -- --bin-dir /usr/local/bin --man-dir /usr/local/share/man >/dev/null
    # Install copyparty from source - requires python3
    [ -n "$COPYPARTY_VERSION" ] && \
        curl -sSfLo copyparty "$COPYPARTY_URL/copyparty-sfx.py" && \
        sudo install copyparty /usr/local/bin && rm copyparty
    # Install jdupes from source
    JDUPES_URL=https://codeberg.org/jbruchon/jdupes
    JDUPES_VERSION=$(curl -sSfL "$JDUPES_URL/releases/latest" | grep -oP '(?<=href="/jbruchon/jdupes/src/tag/v).+(?=" rel)')
    [ -n "$JDUPES_VERSION" ] && \
        curl -sSfL "$JDUPES_URL/releases/download/v$JDUPES_VERSION/jdupes-$JDUPES_VERSION-linux-x86_64.pkg.tar.xz" |\
            unxz | tar xf - "jdupes-$JDUPES_VERSION-linux-x86_64/jdupes" --strip-components=1 && \
        curl -sSfL "$JDUPES_URL/archive/v$JDUPES_VERSION.tar.gz" | tar xz jdupes/jdupes.1 --strip-components=1 && \
        sudo install jdupes /usr/local/bin && sudo mv jdupes.1 /usr/local/share/man/man1 && rm jdupes
    # Required for running portable binaries on certain Linux distributions
    [ -f "/lib/ld-linux-x86-64.so.2" ] || sudo ln -s /lib64/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2
}

common_user_install() {
    echo_with_date "Running common user install"
    # Create the top level directories before stowing so that stow does not symlink from the top level
    mkdir -p "$HOME/.config/"{nvim,tmux,yazi,zsh,q} "$HOME/.vim"
    # Clone the dotfiles
    [ -d "$HOME/dotfiles" ] || git clone --depth=10 https://github.com/mau-mauricelim/dotfiles.git "$HOME/dotfiles" >/dev/null
    # Copy the q folder as static files
    cp -r "$HOME/dotfiles/q" "$HOME"
    # Stow the dotfiles
    cd "$HOME/dotfiles" && git pull https://github.com/mau-mauricelim/dotfiles.git HEAD && \
        git remote set-url origin git@github.com:mau-mauricelim/dotfiles.git && \
        stow . && git restore . && cd "$HOME" || exit 1
    # Create a symlink for zshenv to HOME
    ln -sf "$HOME/.config/zsh/.zshenv" "$HOME/.zshenv"
    # Source the latest zshenv
    source "$HOME/.zshenv"
    # Create ZDOTDIR and XDG_DATA_HOME directories
    mkdir -p "$ZDOTDIR" "$XDG_DATA_HOME/"{nvim,vim}/{undo,swap,backup}
    # Zsh Theme - Powerlevel10k (Requires manual font installation)
    [ -d "$ZDOTDIR/powerlevel10k" ] || git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZDOTDIR/powerlevel10k"
    # Zsh Auto Suggestions
    [ -d "$ZDOTDIR/zsh-autosuggestions" ] || git clone -q --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZDOTDIR/zsh-autosuggestions"
    # Zsh Syntax Highlighting
    [ -d "$ZDOTDIR/fast-syntax-highlighting" ] || git clone -q --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZDOTDIR/fast-syntax-highlighting"
    # fzf
    [ -d "$ZDOTDIR/fzf" ] || git clone -q --depth 1 https://github.com/junegunn/fzf.git "$ZDOTDIR/fzf"
    # fzf-tab
    [ -d "$ZDOTDIR/fzf-tab" ] || git clone -q --depth 1 https://github.com/Aloxaf/fzf-tab "$ZDOTDIR/fzf-tab"
    command -v fzf >/dev/null || "$ZDOTDIR/fzf/install" --xdg --no-update-rc --completion --key-bindings >/dev/null 2>&1
    # Symlink Vim syntax and indent files to Neovim
    ln -sf "$HOME/.vim/indent" "$XDG_CONFIG_HOME/nvim" && \
        ln -sf "$HOME/.vim/syntax" "$XDG_CONFIG_HOME/nvim"
    # bash and zsh key bindings for Git objects, powered by fzf.
    [ -f "$XDG_CONFIG_HOME/fzf/fzf-git.sh" ] || curl -sSfLo "$XDG_CONFIG_HOME/fzf/fzf-git.sh" https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh
    # Install nvm, node.js, and npm
    if ! command -v npm >/dev/null; then
        PROFILE=/dev/null bash -c 'curl -so- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >/dev/null' && \
            export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "$HOME/.nvm" || printf %s "$XDG_CONFIG_HOME/nvm")"; \
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
            nvm install node >/dev/null
    fi
    # Install q language server for neovim
    sudo npm --global i @jo.shinonome/qls yarn || npm --global i @jo.shinonome/qls yarn
    # Install yazi themes
    git clone -q --depth=1 https://github.com/yazi-rs/flavors.git flavors && \
        mkdir -p "$XDG_CONFIG_HOME/yazi/flavors" && \
        cp -r flavors/*.yazi "$XDG_CONFIG_HOME/yazi/flavors" && rm -rf flavors
    # Full install
    if [ "$INSTALL_TYPE" = "full" ]; then
        # TPM installation
        git clone -q --depth=1 https://github.com/tmux-plugins/tpm "$XDG_CONFIG_HOME/tmux/plugins/tpm" && "$XDG_CONFIG_HOME/tmux/plugins/tpm/bin/install_plugins"
        # Run Lazy install, clean and update non-interactively from command line inside tmux
        tmux new -d -s nvim-install \; \
            send-keys "timeout 60 nvim --headless '+Lazy! sync' +qa 2>&1 | tee /tmp/lazy.log" C-m \; \
            send-keys "timeout 60 nvim --headless '+MasonToolsInstallSync' +qa 2>&1 | tee /tmp/mason.log" C-m \; \
            send-keys "timeout 60 nvim --headless '+TSUpdate' +qa 2>&1 | tee /tmp/ts.log" C-m \; \
            send-keys "exit" C-m && \
            while tmux has-session -t nvim-install 2>/dev/null; do sleep 2; done
        echo_with_date "Lazy Sync output:"
        cat /tmp/lazy.log
        echo_with_date "Mason Tools Install Sync output:"
        cat /tmp/mason.log
        echo_with_date "Treesitter Update output:"
        cat /tmp/treesitter.log
    fi
    # Start zsh and exit (It'll allow powerlevel10k to do everything it needs to do on first run.)
    echo exit | script -qec zsh /dev/null >/dev/null
    # Set Zsh as the default shell
    sudo chsh -s "$(which zsh)"
    # Clear the npm cache
    [ -d "$HOME/.npm" ] && rm -rf "$HOME/.npm"
    # Clean up tmp directories
    sudo rm -rf /tmp/tmp.*
}

install_fd() {
    [ -n "$FD_VERSION" ] && \
        curl -sSfL "$FD_URL/fd-v$FD_VERSION-x86_64-unknown-linux-$1.tar.gz" \
            | tar xz "fd-v$FD_VERSION-x86_64-unknown-linux-$1/fd" "fd-v$FD_VERSION-x86_64-unknown-linux-$1/fd.1" --strip-components=1 && \
        sudo install fd /usr/local/bin && sudo mv fd.1 /usr/local/share/man/man1 && rm fd
}

install_bat() {
    [ -n "$BAT_VERSION" ] && \
        curl -sSfL "$BAT_URL/bat-v$BAT_VERSION-x86_64-unknown-linux-$1.tar.gz" \
            | tar xz "bat-v$BAT_VERSION-x86_64-unknown-linux-$1/bat" "bat-v$BAT_VERSION-x86_64-unknown-linux-$1/bat.1" --strip-components=1 && \
        sudo install bat /usr/local/bin && sudo mv bat.1 /usr/local/share/man/man1 && rm bat
}

install_hyperfine() {
    [ -n "$HYPERFINE_VERSION" ] && \
        curl -sSfL "$HYPERFINE_URL/hyperfine-v$HYPERFINE_VERSION-x86_64-unknown-linux-$1.tar.gz" \
            | tar xz "hyperfine-v$HYPERFINE_VERSION-x86_64-unknown-linux-$1/hyperfine" "hyperfine-v$HYPERFINE_VERSION-x86_64-unknown-linux-$1/hyperfine.1" --strip-components=1 && \
        sudo install hyperfine /usr/local/bin && sudo mv hyperfine.1 /usr/local/share/man/man1 && rm hyperfine
}

install_eza() {
    [ -n "$EZA_VERSION" ] && \
        curl -sSfL "$EZA_URL/eza_x86_64-unknown-linux-$1.tar.gz" | tar xz && \
        curl -sSfL "$EZA_URL/man-$EZA_VERSION.tar.gz" | tar xz "./target/man-$EZA_VERSION/eza.1" --strip-components=3 && \
        sudo install eza /usr/local/bin && sudo mv eza.1 /usr/local/share/man/man1 && rm eza
}

install_delta() {
    [ -n "$DELTA_VERSION" ] && \
        curl -sSfL "$DELTA_URL/delta-$DELTA_VERSION-x86_64-unknown-linux-$1.tar.gz" \
            | tar xz "delta-$DELTA_VERSION-x86_64-unknown-linux-$1/delta" --strip-components=1 && \
        sudo install delta /usr/local/bin && rm delta
}

install_yazi() {
    [ -n "$YAZI_VERSION" ] && \
        curl -sSfLo yazi.zip "$YAZI_URL/yazi-x86_64-unknown-linux-$1.zip" && \
        unzip -qj yazi.zip "yazi-x86_64-unknown-linux-$1/yazi" && \
        sudo install yazi /usr/local/bin && rm yazi yazi.zip
}

# Alpine uses MUSL binaries
alpine_install() {
    # Install required packages
    # coreutils is for dircolors
    # procps is for vim-tmux-navigator
    # build-base installs a C compiler for nvim-treesitter
    # Busybox binaries (default) doesn't support all features. E.g. `grep -P`
    # util-linux-misc is for script and column
    # docs installs the documentation companion package
    # shadow is for chsh and usermod
    # ncurses installs tput for fzf-git (fzf-tmux)
    # gcompat is for q
    # python3 is for copyparty
    sudo apk -q --no-progress --no-cache add \
        tar bzip2 rlwrap curl git vim stow openssh tmux grep neovim exiftool \
        mandoc man-pages less docs \
        zsh coreutils procps build-base xclip util-linux-misc nodejs npm shadow ncurses gcompat python3
    # Common root installs
    common_root_install
    # Install MUSL binaries from source
    for bin in fd bat hyperfine eza delta yazi; do "install_$bin" musl; done
    # Common user installs
    common_user_install
}

ubuntu_install() {
    # Install required packages
    # ca-certificates is required for build success
    # file is required for yazi
    # build-essential installs a C compiler for nvim-treesitter
    sudo apt-get -qq update >/dev/null 2>&1 && \
        sudo apt-get -qq install -y --no-install-recommends \
            zsh tar bzip2 unzip rlwrap curl ca-certificates git vim man less stow openssh-server tmux file build-essential xclip exiftool >/dev/null
    # Common root installs
    common_root_install
    # Install GNU binaries from source
    for bin in fd bat hyperfine eza delta yazi; do "install_$bin" gnu; done
    # Install GNU Neovim from source
    curl -sSfLO "$NEOVIM_URL/nvim-linux-x86_64.tar.gz" && \
        sudo rm -rf /opt/nvim && \
        sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz && rm nvim-linux-x86_64.tar.gz
    # Common user installs
    common_user_install
    # Clean up
    sudo apt-get -qq remove ca-certificates >/dev/null && \
        sudo apt-get -qq autoclean -y && \
        sudo apt-get -qq clean -y && \
        sudo apt-get -qq autoremove -y >/dev/null && \
        sudo rm -rf /var/cache/apt/archives /var/lib/apt/lists
}

# This is put in braces to ensure that the script does not run until it is downloaded completely
{ main "$@" || exit 1; }
