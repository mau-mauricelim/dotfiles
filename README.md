# ✨ dotfiles

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

## 🐱 GitHub Actions
