# ✨ dotfiles

## Installation
Install via the install script:
- Only supported on Alpine and Ubuntu
```sh
curl -sSfL https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/install.sh | bash
curl -sSfL https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/install.sh | bash -s -- full
```

### [Install custom Distribution to use with 🐧 WSL](docs%2Fwsl.md)

## Manage dotfiles with GNU Stow
```bash
$ git clone -q --depth=1 https://github.com/mau-mauricelim/dotfiles.git
$ cd dotfiles
$ stow . -nv # Simulation mode
$ stow . # OR stow . if .stowrc exists
$ git restore . # OR git reset --hard
```

### 🐚 Shell packages included
- aoc-cli 🎅
- bash 👊
- bat(cat) 🦇 🐈
- bzip2 🤐
- copyparty 💾🎉
- curl 🥌
- delta 🌈
- exiftool 🔨
- eza 📜
- fd 📂
- fzf 🌸
- git 🌳
- hyperfine ⏳
- jdupes 👥
- jq { }
- lazygit 🦥
- less 📟
- neovim 📝
- npm (nvm) 📦
- ripgrep 🔍
- rlwrap 🌯
- ssh 🐚
- sudo 😎
- tar 📼
- tmux 🪟
- unzip 🤐
- vim 📄
- yazi 🦆 (file 📁)
- zoxide 🦘
- zsh 🐚

### 🐚 Useful shell packages
- mpv
- yt-dlp
