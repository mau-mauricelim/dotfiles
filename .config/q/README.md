# Installing kdb+

## Windows Quick install

```cmd
> curl -sSf https://raw.githubusercontent.com/mau-mauricelim/dotfiles/main/.config/q/install.bat -o %tmp%\install.bat && %tmp%\install.bat
```

Download (and unzip) the kdb+ binaries into `C:\q` (`/mnt/c/q`) manually or use [download.sh](./download.sh) in WSL

> [!NOTE]
> - Non KDB-X versions uses the same license key file (KDB PLUS TRIAL)
> - KDB-X uses a different license key file (COMMUNITY)

The directory should look like:
```sh
/mnt/c/q
├── 4.0
│   ├── l32
│   │   └── q
│   ├── l64
│   │   └── q
│   ├── l64arm
│   │   └── q
│   ├── l64nosse
│   │   └── q
│   ├── m32
│   │   └── q
│   ├── m64
│   │   └── q
│   ├── v32
│   │   └── q
│   ├── v64
│   │   └── q
│   ├── w32
│   │   └── q.exe
│   ├── w64
│   │   └── q.exe
│   ├── 2025.02.18
│   ├── kc.lic
│   ├── 'KDB PLUS TRIAL license'
│   ├── q.k
│   └── README.txt
├── 4.1
│   ├── l32
│   │   └── q
│   ├── l64
│   │   └── q
│   ├── l64arm
│   │   └── q
│   ├── l64nosse
│   │   └── q
│   ├── m64
│   │   └── q
│   ├── w32
│   │   └── q.exe
│   ├── w64
│   │   └── q.exe
│   ├── 2025.11.25
│   ├── kc.lic
│   ├── 'KDB PLUS TRIAL license'
│   ├── q.k
│   └── README.txt
└── x
    ├── l32
    │   └── q
    ├── l64
    │   └── q
    ├── l64arm
    │   └── q
    ├── l64nosse
    │   └── q
    ├── m64
    │   └── q
    ├── w32
    │   └── q.exe
    ├── w64
    │   └── q.exe
    ├── 2025.11.17
    ├── 'COMMUNITY license'
    ├── kc.lic
    └── README.txt
```

### Running multiple versions of kdb+ using [q.bat](./q.bat)
[q.bat](./q.bat) is a wrapper script for running multiple versions of kdb+

Usage:
```cmd
q
q <version>
q 4.0
q 4.1
q x
```

<details>
    <summary>The following setup steps can be skipped when using the <a href="#windows-quick-install">quick installer</a></summary>

Edit enviroment variables for your account:
```cmd
echo %PATH% | find /i "C:\q" > nul || set PATH=%PATH%;"C:\q"
setx QINIT C:\q\q.q
```

Create a Start Menu shortcut:
- Right-click on `q.bat` > `Create shortcut`
- Move the shortcut to: `%APPDATA%\Microsoft\Windows\Start Menu\Programs`
- `Rename` the shortcut to the same name as the program (`q.bat`/`q`)
- Open the start menu and search `q.bat`/`q` to launch it
- `Pin to Start`
</details>

## WSL
The `QINIT` file can be a windows symlink to a file in WSL distro

Example:
```cmd
mklink C:\q\q.q \\wsl.localhost\<distro name>\home\<user>\q.q
```

### Musl libc
Linux kdb+ binaries are compiled against glibc
- To run them, glibc compatibility layer for musl is required: https://github.com/Stantheman/gcompat
- Example: Alpine Linux: `sudo apk add gcompat`

HACK: For distros that uses musl but does not support gcompat:
- The convoluted solution is to run the windows kdb+ binaries
- WARN: There may be compatibility issues

HACK: To run multiple versions of windows kdb+ binaries inside these distros:
- The alias of q and the q version requires to copy its `q.k` file into the default `QHOME` directory which is `C:\q`
- WARN: Do not set the windows environment variables: `QHOME` and `QLIC`

### (Glibc) GNU C Library
These distros can run the linux kdb+ binaries
