#!/usr/bin/env bash
main() {
    source /etc/os-release
    case $ID in
        alpine|ubuntu)
            run_install $ID
            ;;
        *)
            echo "$ID is not supported"
            ;;
    esac
}

run_install() { echo "Running $1 installer"; "${1}_install"; }

get_binary_version() {
    latest_release=$(curl -sL "https://api.github.com/repos/$1/releases/latest")
    if [ "$2" = "true" ]; then
        echo "${latest_release}" | grep -Po '"tag_name": "v\K[^"]*' # strip v from tag
    else
        echo "${latest_release}" | grep tag_name | cut -d '"' -f4
    fi
}

set_binary_version() {
    JQ_VERSION=$(get_binary_version "jqlang/jq")
    YAZI_VERSION=$(get_binary_version "sxyazi/yazi")
    DELTA_VERSION=$(get_binary_version "dandavison/delta")
    RIPGREP_VERSION=$(get_binary_version "BurntSushi/ripgrep")
    FD_VERSION=$(get_binary_version "sharkdp/fd" true)
    BAT_VERSION=$(get_binary_version "sharkdp/bat" true)
    EZA_VERSION=$(get_binary_version "eza-community/eza" true)
    LAZYGIT_VERSION=$(get_binary_version "jesseduffield/lazygit" true)
}

# TODO: change all github downloads usl to /latest/!

common_root_install() {
    # Manual install of man pages for release binaries
    sudo mkdir -p /usr/local/share/man/man1
    # Set binary version
    set_binary_version
    # Install MUSL ripgrep from source
    [ -n "$RIPGREP_VERSION" ] && \
        curl -sL "https://github.com/BurntSushi/ripgrep/releases/lastest/ripgrep-$RIPGREP_VERSION-x86_64-unknown-linux-musl.tar.gz" \
            | tar xz "ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/rg" "ripgrep-$RIPGREP_VERSION-x86_64-unknown-linux-musl/doc/rg.1" --strip-components=1 && \
        sudo install rg /usr/local/bin && sudo mv doc/rg.1 /usr/local/share/man/man1 && rm -r rg doc
    # Install LINUX lazygit from source
    [ -n "$LAZYGIT_VERSION" ] && \
        curl -sL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
            | tar xz lazygit && \
        sudo install lazygit /usr/local/bin && rm lazygit
    # Install LINUX jq
    [ -n "$JQ_VERSION" ] && \
        curl -sLo jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 && \
        curl -sL "https://github.com/jqlang/jq/releases/latest/download/$JQ_VERSION.tar.gz" | tar xz "$JQ_VERSION/jq.1" --strip-components=1 && \
        sudo install jq /usr/local/bin && sudo mv jq.1 /usr/local/share/man/man1 && rm jq
    # Install zoxide
    curl -sLS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- --bin-dir /usr/local/bin --man-dir /usr/local/share/man
}

common_user_install() {
    # Create the top level directories before stowing so that stow does not symlink from the top level
    mkdir -p "$HOME/.config/{nvim,tmux,yazi,zsh}" "$HOME/.vim"
    # Stow the dotfiles
    git clone --depth=1 "https://github.com/mau-mauricelim/dotfiles.git" "$HOME/dotfiles" && \
        cd "$HOME/dotfiles" && git remote set-url origin git@github.com:mau-mauricelim/dotfiles.git && \
        stow . && git restore . && cd "$HOME" || exit
    # Install local binaries
    sudo install "$HOME/dotfiles/bin/*" /usr/local/bin
    # Create a symlink for zshenv to HOME
    ln -sf "$HOME/.config/zsh/.zshenv" "$HOME/.zshenv"
    # Source the latest zshenv
    source "$HOME/.zshenv"
    # Create ZDOTDIR and XDG_DATA_HOME directories
    mkdir -p "$ZDOTDIR" "$XDG_DATA_HOME/{nvim,vim}/{undo,swap,backup}"
    # Zsh Theme - Powerlevel10k (Requires manual font installation)
    git clone -q --depth=1 "https://github.com/romkatv/powerlevel10k.git" "$ZDOTDIR/powerlevel10k"
    # Zsh Auto Suggestions
    git clone -q --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZDOTDIR/zsh-autosuggestions"
    # Zsh Syntax Highlighting
    git clone -q --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZDOTDIR/zsh-syntax-highlighting"
    # fzf
    git clone -q --depth 1 https://github.com/junegunn/fzf.git "$ZDOTDIR/fzf" && \
        "$ZDOTDIR/fzf/install" --xdg --no-update-rc --completion --key-bindings >/dev/null 2>&1
    # Vim syntax and indent
    mkdir -p "$HOME/.vim/{indent,syntax}" && \
        git clone -q --depth=1 https://github.com/katusk/vim-qkdb-syntax.git "$HOME/.vim/vim-qkdb-syntax" && \
            ln -sf "$HOME/.vim/vim-qkdb-syntax/indent/{k,q}.vim" "$HOME/.vim/indent" && \
            ln -sf "$HOME/.vim/vim-qkdb-syntax/syntax/k.vim" "$HOME/.vim/syntax" && \
        git clone -q --depth=1 https://github.com/jshinonome/vim-q-syntax.git "$HOME/.vim/vim-q-syntax" && \
            ln -sf "$HOME/.vim/vim-q-syntax/syntax/q.vim" "$HOME/.vim/syntax"
    # Symlink Vim syntax and indent files to Neovim
    ln -sf "$HOME/.vim/indent" "$XDG_CONFIG_HOME/nvim" && \
        ln -sf "$HOME/.vim/syntax" "$XDG_CONFIG_HOME/nvim"
    # bash and zsh key bindings for Git objects, powered by fzf.
    curl -sLo "$XDG_CONFIG_HOME/fzf/fzf-git.sh" https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh
    # TPM installation
    # git clone -q --depth=1 https://github.com/tmux-plugins/tpm $XDG_CONFIG_HOME/tmux/plugins/tpm && $XDG_CONFIG_HOME/tmux/plugins/tpm/bin/install_plugins
    # Install nvm, node.js, and npm
    if ! command -v npm >/dev/null; then
        PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash' && \
            export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "$HOME/.nvm" || printf %s "$XDG_CONFIG_HOME/nvm")"; \
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
            nvm install node
    fi
    # Install q language server for neovim
    npm --global i @jo.shinonome/qls || sudo npm --global i @jo.shinonome/qls
    # Install yazi themes
    git clone -q --depth=1 https://github.com/yazi-rs/flavors.git flavors && \
        mkdir -p "$XDG_CONFIG_HOME/yazi/flavors" && \
        mv flavors/*.yazi "$XDG_CONFIG_HOME/yazi/flavors" && rm -rf flavors
    # Run Lazy install, clean and update non-interactively from command line
    # nvim --headless '+Lazy! sync' +qa
    # Start zsh and exit (It'll allow powerlevel10k to do everything it needs to do on first run.)
    echo exit | script -qec zsh /dev/null >/dev/null
    # Set Zsh as the default shell
    sudo chsh -s "$(which zsh)"
}

install_fd() {
    [ -n "$FD_VERSION" ] && \
        curl -sL "https://github.com/sharkdp/fd/releases/latest/fd-v$FD_VERSION-x86_64-unknown-linux-$1.tar.gz" \
            | tar xz "fd-v$FD_VERSION-x86_64-unknown-linux-$1/fd" "fd-v$FD_VERSION-x86_64-unknown-linux-$1/fd.1" --strip-components=1 && \
        sudo install fd /usr/local/bin && sudo mv fd.1 /usr/local/share/man/man1 && rm fd
}

install_bat() {
    [ -n "$BAT_VERSION" ] && \
        curl -sL "https://github.com/sharkdp/bat/releases/latest/bat-v$BAT_VERSION-x86_64-unknown-linux-$1.tar.gz" \
            | tar xz "bat-v$BAT_VERSION-x86_64-unknown-linux-$1/bat" "bat-v$BAT_VERSION-x86_64-unknown-linux-$1/bat.1" --strip-components=1 && \
        sudo install bat /usr/local/bin && sudo mv bat.1 /usr/local/share/man/man1 && rm bat
}

install_eza() {
    [ -n "$EZA_VERSION" ] && \
        curl -sL "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-$1.tar.gz" | tar xz && \
        curl -sL "https://github.com/eza-community/eza/releases/latest/download/man-$EZA_VERSION.tar.gz" | tar xz "./target/man-$EZA_VERSION/eza.1" --strip-components=3 && \
        sudo install eza /usr/local/bin && sudo mv eza.1 /usr/local/share/man/man1 && rm eza
}

install_delta() {
    [ -n "$DELTA_VERSION" ] && \
        curl -sL "https://github.com/dandavison/delta/releases/latest/download/delta-$DELTA_VERSION-x86_64-unknown-linux-$1.tar.gz" \
            | tar xz "delta-$DELTA_VERSION-x86_64-unknown-linux-$1/delta" --strip-components=1 && \
        sudo install delta /usr/local/bin && rm delta
}

install_yazi() {
    [ -n "$YAZI_VERSION" ] && \
        curl -sLo yazi.zip "https://github.com/sxyazi/yazi/releases/latest/yazi-x86_64-unknown-linux-$1.zip" && \
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
    # util-linux-misc is for script
    # docs installs the documentation companion package
    # shadow is for chsh
    sudo apk -q --no-progress --no-cache add \
        tar bzip2 rlwrap curl git vim stow openssh tmux grep neovim \
        mandoc man-pages less docs \
        zsh coreutils procps build-base xclip util-linux-misc nodejs npm shadow
    # Common root installs
    common_root_install
    # Install MUSL binaries from source
    for bin in fd bat eza delta yazi; do "install_$bin" musl; done
    # Common user installs
    common_user_install
    # Clean up
    sudo apk del util-linux-misc shadow
}

ubuntu_install() {
    # Install required packages
    # ca-certificates is required for build success
    # file is required for yazi
    # build-essential installs a C compiler for nvim-treesitter
    sudo apt-get -qq update >/dev/null 2>&1 && \
        sudo apt-get -qq install -y --no-install-recommends \
            zsh tar bzip2 unzip rlwrap curl ca-certificates git vim man less stow openssh-server tmux file build-essential xclip
    # Common root installs
    common_root_install
    # Install GNU binaries from source
    for bin in fd bat eza delta yazi; do "install_$bin" gnu; done
    # Install GNU Neovim from source
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
        sudo rm -rf /opt/nvim && \
        sudo tar -C /opt -xzf nvim-linux64.tar.gz && rm nvim-linux64.tar.gz
    # Common user installs
    common_user_install
    # Clean up
    sudo apt-get -qq remove ca-certificates && \
        sudo apt-get -qq autoclean -y && \
        sudo apt-get -qq clean -y && \
        sudo apt-get -qq autoremove -y && \
        sudo rm -rf /var/cache/apt/archives /var/lib/apt/lists
}

# This is put in braces to ensure that the script does not run until it is downloaded completely
{ main "$@" || exit 1; }
