# ✨ dotfiles

## Installation
Install via the install script:
- Only supported on Alpine and Ubuntu
```sh
curl -sSfL https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/install.sh | bash
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
- sudo
- zsh
- ripgrep
- fd ⚡
- tar
- bzip2
- unzip 🤐
- rlwrap 🌯
- bat(cat) 🦇 🐈
- zoxide
- curl 🥌
- git
- vim
- less
- eza
- neovim
- bash 👊
- fzf 🌸
- lazygit 🦥
- ssh 🐚
- tmux
- npm (nvm)
- yazi 🦆 (file 📁)

## 📝 TODO
- [ ] [codeium](https://github.com/Exafunction/codeium.vim)
- [ ] [Ansible](https://www.ansible.com/)
- [ ] [NixOS](https://nixos.org/)
- [ ] [undotree](https://github.com/mbbill/undotree)
- [ ] [bqf](https://github.com/kevinhwang91/nvim-bqf)
