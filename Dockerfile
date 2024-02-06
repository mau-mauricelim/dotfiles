FROM ubuntu:22.04

# ARG should be after FROM
ARG USERNAME=maurice
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG HOME=/home/$USERNAME

SHELL ["/bin/bash", "-c"]

# Unminimize ubuntu before installing packages
RUN yes | unminimize >/dev/null 2>&1 && \
	# Install required packages
    apt-get -qq update && \
	    apt-get -qq install -y --no-install-recommends \
		    sudo zsh ripgrep fd-find build-essential rlwrap bat zoxide curl gpg ca-certificates git vim openssh-client man less locales && \
    # Install PyPy to replace Python - latest stable release from Tarball
    mkdir /usr/.pypy-linux64 && \
        # URL needs manual update
        curl -s https://downloads.python.org/pypy/pypy3.10-v7.3.15-linux64.tar.bz2 \
            | tar xj -C /usr/.pypy-linux64 --strip-components 1 && \
        ln -sf $(find /usr/.pypy-linux64/bin -type l) /usr/bin && \
	# Install eza
	mkdir -p /etc/apt/keyrings && \
		curl -s https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
		echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list && \
		chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list && \
		apt-get -qq update && \
		apt-get -qq install -y --no-install-recommends eza && \
	# Clean up
	apt-get -qq autoremove -y && \
        apt-get -qq clean -y && \
        rm -rf /var/cache/apt/archives /var/lib/apt/lists && \
	# Create user
	groupadd --gid $USER_GID $USERNAME && \
		# Set Zsh as the default shell
		useradd --uid $USER_UID --gid $USER_GID -m -N -s /bin/zsh $USERNAME && \
		mkdir -p /etc/sudoers.d && \
		echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
		chmod 0440 /etc/sudoers.d/$USERNAME && \
    # Set default user for WSL
    echo -e "[user]\ndefault=$USERNAME" >> /etc/wsl.conf

ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color

# Set default user
USER $USERNAME
WORKDIR $HOME
# Setup dotfiles
COPY --chown=$USERNAME:$USERNAME .bashrc .commonrc .profile $HOME
COPY --chown=$USERNAME:$USERNAME .vim $HOME/.vim
COPY --chown=$USERNAME:$USERNAME .config $HOME/.config

# Create user's private bin
RUN mkdir -p $HOME/.local/bin && \
    # Create a symlink for zshenv to HOME
    ln -s $HOME/.config/zsh/.zshenv $HOME/.zshenv && \
	# Source the latest zshenv
	source $HOME/.zshenv && \
	# Create ZDOTDIR and XDG_DATA_HOME directories
	mkdir -p $HOME/.local/bin $ZDOTDIR $XDG_DATA_HOME/{nvim,vim}/{undo,swap,backup} && \
	# Zsh Theme - Powerlevel10k (Requires manual font installation)
	git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git $ZDOTDIR/powerlevel10k && \
	# Zsh Auto Suggestions
	git clone -q https://github.com/zsh-users/zsh-autosuggestions $ZDOTDIR/zsh-autosuggestions && \
	# Zsh Syntax Highlighting
	git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git $ZDOTDIR/zsh-syntax-highlighting && \
	# Install Neovim - latest stable release from Tarball
	curl -sL https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz | tar xz -C $HOME && \
		mv $HOME/nvim-linux64 $HOME/.nvim-linux64 && \
		ln -s $HOME/.nvim-linux64/bin/nvim $HOME/.local/bin && \
	# Install vim-plug for Vim and Neovim
	curl -sfLo $HOME/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
	curl -sfLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
	# Run PlugInstall non-interactively from command line
	vim +'PlugInstall --sync' +qa && \
		nvim +'PlugInstall --sync' +qa && \
	# Add bat (batcat) and fd (fdfind) to user's private bin
	ln -s /usr/bin/batcat $HOME/.local/bin/bat && \
        ln -s $(which fdfind) $HOME/.local/bin/fd && \
	# fzf
	git clone -q --depth 1 https://github.com/junegunn/fzf.git $ZDOTDIR/fzf && \
		$ZDOTDIR/fzf/install --xdg --no-update-rc --completion --key-bindings >/dev/null 2>&1 && \
	# Vim syntax and indent
	mkdir -p $HOME/.vim/{indent,syntax} && \
		git clone -q https://github.com/katusk/vim-qkdb-syntax.git $HOME/.vim/vim-qkdb-syntax && \
			ln -s $HOME/.vim/vim-qkdb-syntax/indent/{k,q}.vim $HOME/.vim/indent && \
			ln -s $HOME/.vim/vim-qkdb-syntax/syntax/k.vim $HOME/.vim/syntax && \
		git clone -q https://github.com/jshinonome/vim-q-syntax.git $HOME/.vim/vim-q-syntax && \
			ln -s $HOME/.vim/vim-q-syntax/syntax/q.vim $HOME/.vim/syntax && \
	# Symlink Vim syntax and indent files to Neovim
	ln -s $HOME/.vim/filetype.vim $XDG_CONFIG_HOME/nvim && \
		ln -s $HOME/.vim/indent $XDG_CONFIG_HOME/nvim && \
		ln -s $HOME/.vim/syntax $XDG_CONFIG_HOME/nvim && \
	# Ripgrep integration (https://github.com/junegunn/fzf/blob/master/ADVANCED.md#ripgrep-integration)
	chmod +x $XDG_CONFIG_HOME/fzf/rfv && \
		ln -s $XDG_CONFIG_HOME/fzf/rfv $HOME/.local/bin && \
	# bash and zsh key bindings for Git objects, powered by fzf.
	curl -so $XDG_CONFIG_HOME/fzf/fzf-git.sh https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh && \
	# Start zsh and exit (It'll allow powerlevel10k to do everything it needs to do on first run.)
	echo exit | script -qec zsh /dev/null >/dev/null