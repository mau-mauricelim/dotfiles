## Install custom Distribution to use with 🐧 WSL

1. Select the latest release tag and download the assets
2. Unzip the directory and run [install.cmd](src%2Finstall.cmd)

Alternatively:
1. Select the `Actions` tab at the top
2. Select the `Build WSL Distro custom` workflow
3. Select the latest successful ✅ workflow runs
   - If there is none, manually `Run workflow`
4. Under `Artifacts`, select and download the artifact
5. Unzip the directory and run [install.cmd](src%2Finstall.cmd)

### 🐚 Shell packages included
- sudo
- zsh
- ripgrep
- fd(-find)
- tar
- bzip2
- unzip
- rlwrap
- bat(cat)
- zoxide
- curl
- gpg
- git
- vim
- less
- python3
- eza
- neovim
- bash
- fzf
- lazygit
- ssh
- tmux
- nvm
- npm
- file
- yazi

## 🐱 GitHub Actions

### Automating the workflow of [🐳 Docker](#-docker-integration) + [🐧 WSL](#-wsl-integration)

Build WSL custom Distribution workflow

1. Builds the docker image from Dockerfile and pushes it to Docker Hub
2. Runs and export the docker container to a compressed tar.gz archive file
3. Bundles the WSL install script with the installation archive file into an artifact for download

## 🐳 Docker integration

### [Build an image from a Dockerfile](https://docs.docker.com/engine/reference/commandline/build/)
`docker build -t <image_name>:<tag> .`

### [Create and run a new container from an image](https://docs.docker.com/engine/reference/commandline/run/)
`docker run -dit --hostname <hostname> --name <container_name> <image_name>`

### [Execute a command in a running container](https://docs.docker.com/engine/reference/commandline/exec/)
`docker exec -it <container_name> zsh -u <user>`
- To set password for users
    - Use root user and run `passwd`

### [Export a container's filesystem as a tar archive](https://docs.docker.com/engine/reference/commandline/container_export/)
```sh
docker export <container_name> > <file_name>.tar
# compressed tar archive
docker export <container_name> | gzip > <file_name>.tar.gz
```

### Permission denied error
```sh
sudo groupadd docker # Create the docker group if it does not exist
sudo usermod -aG docker $USER # Add your user to the docker group
newgrp docker # Log in to the new docker group (to avoid having to log out / log in again; but if not enough, try to reboot)
```

## 🐧 WSL integration

### [Import the tar file into WSL](https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl/)
`wsl --import <DistroName> <InstallLocation> <InstallTarFile>`
- The `<InstallTarFile>` can be a tar.gz file
- The distribution will be installed to `<InstallLocation>/ext4.vhdx` which is the disk image file of the Linux's root filesystem (virtual hard disk).

### [Add WSL specific components like a default user](https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro#add-wsl-specific-components-like-a-default-user)
Example `/etc/wsl.conf`:
```sh
# Set default user
[user]
default=user
[interop]
appendWindowsPath=false
# Enable Systemd for WSL2 in Windows 11
[boot]
systemd=true
```
Alternatively, you can [change the default user for a distribution](https://learn.microsoft.com/en-us/windows/wsl/basic-commands?source=recommendations#change-the-default-user-for-a-distribution) using PowerShell:
`<DistroName> config --default-user <user>`

### [Run a specific Linux distribution from PowerShell or CMD](https://learn.microsoft.com/en-us/windows/wsl/basic-commands?source=recommendations#run-a-specific-linux-distribution-from-powershell-or-cmd)
`wsl -d <DistroName> -u <user>`

### Sets the distribution as the default
`wsl -s <DistroName>`

### Show detailed information about all distributions
`wsl -l -v`

### [Mount](https://learn.microsoft.com/en-us/windows/wsl/basic-commands?source=recommendations#mount-a-disk-or-device) / [Unmount](https://learn.microsoft.com/en-us/windows/wsl/basic-commands?source=recommendations#unmount-disks) a disk or device
```cmd
wsl --mount <DiskPath>
wsl --unmount <DiskPath>
```

### [Unregister or uninstall a Linux distribution](https://learn.microsoft.com/en-us/windows/wsl/basic-commands?source=recommendations#unregister-or-uninstall-a-linux-distribution)
`wsl --unregister <DistroName>`

### [Install a 🤓 Nerd Font](https://learn.microsoft.com/en-us/windows/terminal/tutorials/custom-prompt-setup#install-a-nerd-font)
Downloads for recommended fonts:
- [Meslo](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip)
- [JetBrains Mono](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip)

Installation:
1. Unzip the directory
2. Select all the fonts
3. Right-click and "Install all"
> HINT: It might be useful to disable ligatures.

Windows Terminal Usage:
1. Open up Settings in Windows Terminal `Ctrl-,`
2. Select the Profile(s) that you want to apply the font
3. Scroll down to "Additional Settings" and click "Appearance"
4. Change "Font face" and hit "Save"
5. Additionally, to disable ligatures, click "Open JSON file" and edit:
```json
"font": {
   "face": "JetBrainsMono Nerd Font",
   "features": {
      "calt": 0,
   },
},
```
