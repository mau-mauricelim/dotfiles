#!/usr/bin/env bash
# TODO: check if we need to use bash
# Run this script with `sudo`
# Check and invoke sudo if not ran if sudo rights

source /etc/os-release

main() {
    case $ID in
        alpine)
            echo "Running alpine installer"
            alpine_install
            ;;
        ubuntu)
            echo "Running ubuntu installer"
            ;;
        *)
            echo "$ID is not supported"
            ;;
    esac
}

get_binary_version() {
    RIPGREP_VERSION=$(curl -sL "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep tag_name | cut -d '"' -f4)
    FD_VERSION=$(curl -sL "https://api.github.com/repos/sharkdp/fd/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    BAT_VERSION=$(curl -sL "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    EZA_VERSION=$(curl -sL "https://api.github.com/repos/eza-community/eza/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    DELTA_VERSION=$(curl -sL "https://api.github.com/repos/dandavison/delta/releases/latest" | grep tag_name | cut -d '"' -f4)
    YAZI_VERSION=$(curl -sL "https://api.github.com/repos/sxyazi/yazi/releases/latest" | grep tag_name | cut -d '"' -f4)
    LAZYGIT_VERSION=$(curl -sL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    JQ_VERSION=$(curl -sL "https://api.github.com/repos/jqlang/jq/releases/latest" | grep tag_name | cut -d '"' -f4)
}

common_root_install() {
    # Manual install of man pages for release binaries
    mkdir -p /usr/local/share/man/man1
    # Get binary version
    get_binary_version
    # Install MUSL ripgrep from source
    [ ! -z "${RIPGREP_VERSION}" ] && \
        curl -sL https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz \
            | tar xz ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/rg ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/doc/rg.1 --strip-components=1 && \
        install rg /usr/local/bin && mv doc/rg.1 /usr/local/share/man/man1 && rm -r rg doc
    # Install LINUX lazygit from source
    [ ! -z "${LAZYGIT_VERSION}" ] && \
        curl -sL https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz \
            | tar xz lazygit && \
        install lazygit /usr/local/bin && rm lazygit
    # Install LINUX jq
    [ ! -z "${JQ_VERSION}" ] && \
        curl -sLo jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 && \
        curl -sL https://github.com/jqlang/jq/releases/latest/download/${JQ_VERSION}.tar.gz | tar xz ${JQ_VERSION}/jq.1 --strip-components=1 && \
        install jq /usr/local/bin && mv jq.1 /usr/local/share/man/man1 && rm jq
    # Install zoxide
    curl -sLS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- --bin-dir /usr/local/bin --man-dir /usr/local/share/man
}

common_user_install() {
    # Create the top level directories before stowing so that stow does not symlink from the top level
    mkdir -p $HOME/.config/{nvim,tmux,yazi,zsh} $HOME/.vim
    # Stow the dotfiles
    git clone -q --depth=1 https://github.com/mau-mauricelim/dotfiles.git $HOME/dotfiles && \
        cd $HOME/dotfiles && git remote set-url origin git@github.com:mau-mauricelim/dotfiles.git && \
        stow . && git restore . && cd $HOME
    # Install local binaries
    install $HOME/dotfiles/bin/* /usr/local/bin
    # Create a symlink for zshenv to HOME
    ln -sf $HOME/.config/zsh/.zshenv $HOME/.zshenv
    # Source the latest zshenv
    source $HOME/.zshenv
    # Create ZDOTDIR and XDG_DATA_HOME directories
    mkdir -p $ZDOTDIR $XDG_DATA_HOME/{nvim,vim}/{undo,swap,backup}
    # Zsh Theme - Powerlevel10k (Requires manual font installation)
    git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git $ZDOTDIR/powerlevel10k
    # Zsh Auto Suggestions
    git clone -q --depth=1 https://github.com/zsh-users/zsh-autosuggestions $ZDOTDIR/zsh-autosuggestions
    # Zsh Syntax Highlighting
    git clone -q --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZDOTDIR/zsh-syntax-highlighting
    # fzf
    git clone -q --depth 1 https://github.com/junegunn/fzf.git $ZDOTDIR/fzf && \
        $ZDOTDIR/fzf/install --xdg --no-update-rc --completion --key-bindings >/dev/null 2>&1
    # Vim syntax and indent
    mkdir -p $HOME/.vim/{indent,syntax} && \
        git clone -q --depth=1 https://github.com/katusk/vim-qkdb-syntax.git $HOME/.vim/vim-qkdb-syntax && \
            ln -sf $HOME/.vim/vim-qkdb-syntax/indent/{k,q}.vim $HOME/.vim/indent && \
            ln -sf $HOME/.vim/vim-qkdb-syntax/syntax/k.vim $HOME/.vim/syntax && \
        git clone -q --depth=1 https://github.com/jshinonome/vim-q-syntax.git $HOME/.vim/vim-q-syntax && \
            ln -sf $HOME/.vim/vim-q-syntax/syntax/q.vim $HOME/.vim/syntax
    # Symlink Vim syntax and indent files to Neovim
    ln -sf $HOME/.vim/indent $XDG_CONFIG_HOME/nvim && \
        ln -sf $HOME/.vim/syntax $XDG_CONFIG_HOME/nvim
    # bash and zsh key bindings for Git objects, powered by fzf.
    curl -sLo $XDG_CONFIG_HOME/fzf/fzf-git.sh https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh
    # TPM installation
    # git clone -q --depth=1 https://github.com/tmux-plugins/tpm $XDG_CONFIG_HOME/tmux/plugins/tpm && $XDG_CONFIG_HOME/tmux/plugins/tpm/bin/install_plugins
    # Install q language server for neovim
    npm --global i @jo.shinonome/qls
    # Install yazi themes
    git clone -q --depth=1 https://github.com/yazi-rs/flavors.git flavors && \
        mkdir -p $XDG_CONFIG_HOME/yazi/flavors && \
        mv flavors/*.yazi $XDG_CONFIG_HOME/yazi/flavors && rm -rf flavors
    # Run Lazy install, clean and update non-interactively from command line
    # nvim --headless '+Lazy! sync' +qa
    # Set Zsh as the default shell
    chsh -s $(which zsh)
}

# Alpine uses MUSL binaries
alpine_install() {
    apk -q --no-progress --no-cache add \
        # coreutils is for dircolors, procps is for vim-tmux-navigator
        # build-base installs a C compiler for nvim-treesitter
        zsh coreutils tar bzip2 rlwrap curl git vim stow openssh tmux procps build-base xclip \
        # Busybox binaries (default) doesn't support all features. E.g. `grep -P`
        grep \
        # util-linux-misc is for script
        neovim util-linux-misc nodejs npm \
        # Entry in man
        mandoc man-pages less \
        # Install the documentation companion package
        docs
    # Common root installs
    common_root_install
    # Install MUSL fd from source
    [ ! -z "${FD_VERSION}" ] && \
        curl -sL https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz \
            | tar xz fd-v${FD_VERSION}-x86_64-unknown-linux-musl/fd fd-v${FD_VERSION}-x86_64-unknown-linux-musl/fd.1 --strip-components=1 && \
        install fd /usr/local/bin && mv fd.1 /usr/local/share/man/man1 && rm fd
    # Install MUSL bat from source
    [ ! -z "${BAT_VERSION}" ] && \
        curl -sL https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz \
            | tar xz bat-v${BAT_VERSION}-x86_64-unknown-linux-musl/bat bat-v${BAT_VERSION}-x86_64-unknown-linux-musl/bat.1 --strip-components=1 && \
        install bat /usr/local/bin && mv bat.1 /usr/local/share/man/man1 && rm bat
    # Install MUSL eza from source
    [ ! -z "${EZA_VERSION}" ] && \
        curl -sL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz | tar xz && \
        curl -sL https://github.com/eza-community/eza/releases/latest/download/man-${EZA_VERSION}.tar.gz | tar xz ./target/man-${EZA_VERSION}/eza.1 --strip-components=3 && \
        install eza /usr/local/bin && mv eza.1 /usr/local/share/man/man1 && rm eza
    # Install MUSL delta from source
    [ ! -z "${DELTA_VERSION}" ] && \
        curl -sL https://github.com/dandavison/delta/releases/latest/download/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz \
            | tar xz delta-${DELTA_VERSION}-x86_64-unknown-linux-musl/delta --strip-components=1 && \
        install delta /usr/local/bin && rm delta
    # Install MUSL yazi from source
    [ ! -z "${YAZI_VERSION}" ] && \
        curl -sLo yazi.zip https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-musl.zip && \
        unzip -qj yazi.zip yazi-x86_64-unknown-linux-musl/yazi && \
        install yazi /usr/local/bin && rm yazi yazi.zip
    # Common user installs
    common_user_install
    # Start zsh and exit (It'll allow powerlevel10k to do everything it needs to do on first run.)
    # TODO: check if this uses extra space
    echo exit | script -qec zsh /dev/null >/dev/null
    # Clean up
    apk del util-linux-misc
}

ubuntu_install() {
    # Install nvm, node.js, and npm
    PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash' && \
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"; \
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
        nvm install node
}

# This is put in braces to ensure that the script does not run until it is
# downloaded completely.
{
    main "$@" || exit 1
}
