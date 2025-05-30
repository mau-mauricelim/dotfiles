# Installing kdb+
## Windows
Download (and unzip) the kdb+ binaries into `C:\q` (`/mnt/c/q`)

The directory should look like:
```sh
 /mnt/c/q
├──  4.0
│   ├──  l32
│   │   └──  q
│   ├──  l64
│   │   └──  q
│   ├──  l64arm
│   │   └──  q
│   ├──  l64nosse
│   │   └──  q
│   ├──  m32
│   │   └──  q
│   ├──  m64
│   │   └──  q
│   ├──  v32
│   │   └──  q
│   ├──  v64
│   │   └──  q
│   ├──  w32
│   │   └──  q.exe
│   ├──  w64
│   │   └──  q.exe
│   ├──  2025.02.18
│   ├──  q.k
│   └──  README.txt
├──  4.1
│   ├──  l64
│   │   └──  q
│   ├──  l64arm
│   │   └──  q
│   ├──  l64nosse
│   │   └──  q
│   ├──  m64
│   │   └──  q
│   ├──  w32
│   │   └──  q.exe
│   ├──  w64
│   │   └──  q.exe
│   ├──  2025.04.28
│   ├──  q.k
│   └──  README.txt
├──  kc.lic
├──  q.bat
└──  q.q
```

### Running multiple versions of kdb+ using [q.bat](./q.bat)
[q.bat](./q.bat) is a wrapper script for running multiple versions of kdb+

Edit enviroment variables for your account:
```cmd
echo %PATH% | find /i "C:\q" > nul || set PATH=%PATH%;"C:\q"
setx QINIT C:\q\q.q
```

Usage:
```cmd
q
q <version>
q 4.0
q 4.1
```

Create a shortcut in the Start Menu:
- Right-click on `q.bat` > `Create shortcut`
- Move the shortcut to: `C:\Users\%UserName%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs`
- `Rename` the shortcut to the same name as the program (`q.bat`/`q`)
- Open the start menu and search `q.bat`/`q` to launch it
- `Pin to Start`

## WSL
The file `C:\q\q.q` can be a windows symlink to a file in WSL distro
```cmd
mklink C:\q\q.q \\wsl.localhost\<distro name>\home\<user>\q.q
```

### Musl libc
Linux kdb+ binaries are compiled against glibc.
Distro using musl as its C standard library such as Alpine Linux is unable to run Linux kdb+ binaries natively.

The temporary solution is to run the windows kdb+ binaries.

To run multiple versions of windows kdb+ binaries inside these distros, we need to use some sort of a HACK.
- The alias of the q version requires to copy its q.k file into the default QHOME directory which is C:\q
- Using this method, do not set windows environment QHOME and QLIC

### (Glibc) GNU C Library
These distros can run the linux kdb+ binaries
