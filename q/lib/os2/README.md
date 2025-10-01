# 🖥️ OS Utilities

## OS Information

| OS Name          | .os.name      | .z.o        | .os.type | .os.bits | .os.arch |
| -                | -             | -           | -        | -        | -        |
| Linux            | `linux        | `l32        | `l       | 32i      | `x86     |
|                  |               | `l64        | `l       | 64i      | `x86_64  |
| Linux on ARM     | `linuxArm     | `l64/l64arm | `l       | 64i      | `x86_64  |
| macOS            | `macOS        | `m32        | `m       | 32i      | `x86     |
|                  |               | `m64        | `m       | 64i      | `x86_64  |
| Solaris          | `solaris      | `s32        | `s       | 32i      | `x86     |
|                  |               | `s64        | `s       | 64i      | `x86_64  |
| Solaris on Intel | `solarisIntel | `v32        | `v       | 32i      | `x86     |
|                  |               | `v64        | `v       | 64i      | `x86_64  |
| Windows          | `windows      | `w32        | `w       | 32i      | `x86     |
|                  |               | `w64        | `w       | 64i      | `x86_64  |
| Others           | `unknown      |             |          |          |          |

## Usage examples
> [!NOTE]
> The functions output are dependent on the OS

## Functions with No Arguments

### `.os.pwd` - print name of current/working directory
```q
q).os.pwd`
2025.09.30D03:01:20.886129147 [SYSTEM]: cd
"/home/maurice"
```

### `.os.env` - list environment variables
```q
q).os.env`
2025.09.30D03:03:57.288851032 [SYSTEM]: env
"HISTFILESIZE=10000"
"TMUX=/tmp/tmux-1000/default,17,0"
"LANGUAGE=C.UTF-8"
"USER=maurice"
..
```

### `.os.ver` - list the operating system identification data
```q
q).os.ver`
2025.09.30D03:06:59.042926183 [SYSTEM]: cat /etc/os-release
"NAME=\"Alpine Linux\""
"ID=alpine"
"VERSION_ID=3.22.0"
"PRETTY_NAME=\"Alpine Linux v3.22\""
"HOME_URL=\"https://alpinelinux.org/\""
"BUG_REPORT_URL=\"https://gitlab.alpinelinux.org/alpine/aports/-/issues\""
```

### `.os.nproc` - print the number of processing units available
```q
q).os.nproc`
2025.09.30D03:08:56.385040919 [SYSTEM]: nproc
"16"
```

## Functions with A Single Argument
Most of these functions can take argument of an atom or a (mixed) list.
- It supports most data types that can be converted to a string (path)
  - Example: string/symbol/number/mixed (list)
  - `"100"`, `` `100``, `` `:100`` and `100` are equivalent
- Some functions support regex strings (dependent on OS!)
  - Example: `.os.cp("SOURCE_*";"DIRECTORY")`

### `.os.cd` - change the working directory
*Directory:*
```sh
drwxr-sr-x - dir1
drwxr-sr-x - 'dir2 with space'
.rw-r--r-- 0 file1
.rw-r--r-- 0 'file2 with space'
```

- Notice that ``.os.pwd` `` and ``.os.cd` `` are equivalent
```q
q).os.cd`
2025.09.30D04:15:10.815854540 [SYSTEM]: cd
"/home/maurice/tmp"
q).os.cd`dir1
2025.09.30D04:15:20.463287756 [SYSTEM]: cd dir1
q).os.pwd`
2025.09.30D04:15:20.463511482 [SYSTEM]: cd
"/home/maurice/tmp/dir1"
q).os.cd`..
2025.09.30D04:15:41.236076241 [SYSTEM]: cd ..
q).os.pwd`
2025.09.30D04:15:41.236127098 [SYSTEM]: cd
"/home/maurice/tmp"
q).os.cd"dir2 with space"
2025.09.30D04:16:01.395659140 [SYSTEM]: cd dir2 with space
q).os.pwd`
2025.09.30D04:16:01.395716119 [SYSTEM]: cd
"/home/maurice/tmp/dir2 with space"
```

> [!WARNING]
> Side effect: creates the directory if it does not exist
```q
q).os.cd`dir3
2025.09.30D04:17:26.605081772 [SYSTEM]: cd dir3
q).os.pwd`
2025.09.30D04:17:26.605546708 [SYSTEM]: cd
"/home/maurice/tmp/dir3"
```

#### Changes
*Directory:*
```sh
drwxr-sr-x - dir1
drwxr-sr-x - 'dir2 with space'
drwxr-sr-x - dir3
.rw-r--r-- 0 file1
.rw-r--r-- 0 'file2 with space'
```

### `.os.ls` - list directory contents
Support regex strings
```q
q).os.ls`
2025.09.30D05:13:43.591538595 [SYSTEM]: ls
"dir1"
"dir2 with space"
"dir3"
"file1"
"file2 with space"
q).os.ls("dir1";"dir2 with space";"dir3";"file1";"file2 with space")
2025.09.30D05:17:35.399037791 [SYSTEM]: ls dir1 "dir2 with space" dir3 file1 "file2 with space"
"file1"
"file2 with space"
""
"dir1:"
""
"dir2 with space:"
""
"dir3:"
q).os.ls"*"
2025.09.30D05:16:26.392625867 [SYSTEM]: ls *
"file1"
"file2 with space"
""
"dir1:"
""
"dir2 with space:"
""
"dir3:"
```

### `.os.mkdir` - make directories
```q
q).os.mkdir("dir4 with space/nested dir1";"dir5")
2025.09.30D05:26:38.120886709 [SYSTEM]: mkdir -pv "dir4 with space/nested dir1" dir5
"mkdir: created directory 'dir4 with space'"
"mkdir: created directory 'dir4 with space/nested dir1'"
"mkdir: created directory 'dir5'"
```

#### Changes
*Directory:*
```sh
drwxr-sr-x - /home/maurice/tmp
drwxr-sr-x - ├── dir1
drwxr-sr-x - ├── 'dir2 with space'
drwxr-sr-x - ├── dir3
drwxr-sr-x - ├── 'dir4 with space'
drwxr-sr-x - │   └── 'nested dir1'
drwxr-sr-x - ├── dir5
.rw-r--r-- 0 ├── file1
.rw-r--r-- 0 └── 'file2 with space'
```

### `.os.rmdir` - remove empty directories
```q
q).os.rmdir"dir4 with space"
2025.09.30D05:32:17.970882993 [SYSTEM]: rmdir -v "dir4 with space"
rmdir: failed to remove 'dir4 with space': Directory not empty
'os
  [4]  \rmdir -v "dir4 with space"
       ^
q))\
q).os.rmdir("dir4 with space/nested dir1";"dir5")
2025.09.30D05:33:09.951197376 [SYSTEM]: rmdir -v "dir4 with space/nested dir1" dir5
"rmdir: removing directory, 'dir4 with space/nested dir1'"
"rmdir: removing directory, 'dir5'"
q).os.rmdir"dir*"
2025.09.30D05:33:41.232027958 [SYSTEM]: rmdir -v dir*
"rmdir: removing directory, 'dir1'"
"rmdir: removing directory, 'dir2 with space'"
"rmdir: removing directory, 'dir3'"
"rmdir: removing directory, 'dir4 with space'"
```

#### Changes
*Directory:*
```sh
.rw-r--r-- 0 file1
.rw-r--r-- 0 'file2 with space'
```

### `.os.rm` - remove files
*Directory:*
```sh
drwxr-sr-x - /home/maurice/tmp
drwxr-sr-x - ├── dir1
.rw-r--r-- 0 │   └── 'nested file1'
.rw-r--r-- 0 ├── file1
.rw-r--r-- 0 ├── 'file2 with space'
.rw-r--r-- 0 ├── file3
.rw-r--r-- 0 ├── 'file4 with space'
.rw-r--r-- 0 └── file5
```

```q
q).os.rm("dir1/nested file1";`file1;"file2 with space") / Mixed list
2025.09.30D07:55:38.660256562 [SYSTEM]: rm -v "dir1/nested file1" file1 "file2 with space"
"removed 'dir1/nested file1'"
"removed 'file1'"
"removed 'file2 with space'"
q).os.rm"file*"
2025.09.30D08:04:27.214947701 [SYSTEM]: rm -v file*
"removed 'file3'"
"removed 'file4 with space'"
"removed 'file5'"
```

#### Changes
*Directory:*
```sh
drwxr-sr-x - dir1
```

### `.os.rmrf` - force remove files or directories recursively
*Directory:*
```sh
drwxr-sr-x - /home/maurice/tmp
drwxr-sr-x - ├── 'dir1 with space'
drwxr-sr-x - │   ├── 'nested dir1'
.rw-r--r-- 0 │   │   └── 'nested file2'
.rw-r--r-- 0 │   └── 'nested file1'
drwxr-sr-x - ├── dir2
.rw-r--r-- 0 └── file1
```

```q
q).os.rmrf("dir1 with space";`dir2;`file1)
2025.09.30D09:21:54.585250103 [SYSTEM]: rm -rfv "dir1 with space" dir2 file1
"removed 'dir1 with space/nested dir1/nested file2'"
"removed directory 'dir1 with space/nested dir1'"
"removed 'dir1 with space/nested file1'"
"removed directory 'dir1 with space'"
"removed directory 'dir2'"
"removed 'file1'"
```

#### Changes
*Directory:*
```sh
drwxr-sr-x - /home/maurice/tmp
```

### `.os.mv` - move (rename) files
*Directory:*
```sh
drwxr-sr-x - dir1
drwxr-sr-x - dir2
.rw-r--r-- 0 file1
.rw-r--r-- 0 file2
.rw-r--r-- 0 file3
.rw-r--r-- 0 file4
.rw-r--r-- 0 file5
```

Move files to directory:
```q
q).os.mv`file1`file2`file3`dir1
2025.09.30D09:35:31.776592877 [SYSTEM]: mv -v file1 file2 file3 dir1
"renamed 'file1' -> 'dir1/file1'"
"renamed 'file2' -> 'dir1/file2'"
"renamed 'file3' -> 'dir1/file3'"
q).os.mv("file*";`dir1)
2025.09.30D09:36:01.050930753 [SYSTEM]: mv -v file* dir1
"renamed 'file4' -> 'dir1/file4'"
"renamed 'file5' -> 'dir1/file5'"
```

Move (rename) file:
```q
q)`:file6 set test:([]a:til 10;b:10?`5)
`:file6
q).os.mv`file6`file7
2025.09.30D09:37:30.023087547 [SYSTEM]: mv -v file6 file7
"renamed 'file6' -> 'file7'"
q)test~get`:file7
1b
```

Move files (and directories) to directory:
```q
q).os.mv`dir1`file7`dir2
2025.09.30D09:47:01.327539686 [SYSTEM]: mv -v dir1 file7 dir2
"renamed 'dir1' -> 'dir2/dir1'"
"renamed 'file7' -> 'dir2/file7'"
```

#### Changes
*Directory:*
```sh
drwxr-sr-x   - /home/maurice/tmp
drwxr-sr-x   - └── dir2
drwxr-sr-x   -     ├── dir1
.rw-r--r--   0     │   ├── file1
.rw-r--r--   0     │   ├── file2
.rw-r--r--   0     │   ├── file3
.rw-r--r--   0     │   ├── file4
.rw-r--r--   0     │   └── file5
.rw-r--r-- 173     └── file7
```

### `.os.cp` - copy files and directories
*Directory:*
```sh
drwxr-sr-x - dir1
drwxr-sr-x - dir2
.rw-r--r-- 0 file1
.rw-r--r-- 0 file2
.rw-r--r-- 0 file3
.rw-r--r-- 0 file4
.rw-r--r-- 0 file5
```

Copy files to directory:
```q
q).os.cp`file1`file2`file3`dir1
2025.09.30D09:52:05.388116319 [SYSTEM]: cp -v file1 file2 file3 dir1
"'file1' -> 'dir1/file1'"
"'file2' -> 'dir1/file2'"
"'file3' -> 'dir1/file3'"
q).os.cp("file*";`dir2)
2025.09.30D09:52:13.727766383 [SYSTEM]: cp -v file* dir2
"'file1' -> 'dir2/file1'"
"'file2' -> 'dir2/file2'"
"'file3' -> 'dir2/file3'"
"'file4' -> 'dir2/file4'"
"'file5' -> 'dir2/file5'"
```

Copy file:
```q
q)`:file6 set test:([]a:til 10;b:10?`5)
`:file6
q).os.cp`file6`file7
2025.09.30D09:53:57.896250672 [SYSTEM]: cp -v file6 file7
"'file6' -> 'file7'"
q)test~get`:file7
1b
```

#### Changes
*Directory:*
```sh
drwxr-sr-x   - /home/maurice/tmp
drwxr-sr-x   - ├── dir1
.rw-r--r--   0 │   ├── file1
.rw-r--r--   0 │   ├── file2
.rw-r--r--   0 │   └── file3
drwxr-sr-x   - ├── dir2
.rw-r--r--   0 │   ├── file1
.rw-r--r--   0 │   ├── file2
.rw-r--r--   0 │   ├── file3
.rw-r--r--   0 │   ├── file4
.rw-r--r--   0 │   └── file5
.rw-r--r--   0 ├── file1
.rw-r--r--   0 ├── file2
.rw-r--r--   0 ├── file3
.rw-r--r--   0 ├── file4
.rw-r--r--   0 ├── file5
.rw-r--r-- 173 ├── file6
.rw-r--r-- 173 └── file7
```

### `.os.cpr` - copy files and directories recursively
Copy files (and directories) to directory:
```q
q).os.cpr`dir1`file7`dir2
2025.09.30D09:59:16.957703114 [SYSTEM]: cp -rv dir1 file7 dir2
"'dir1' -> 'dir2/dir1'"
"'dir1/file1' -> 'dir2/dir1/file1'"
"'dir1/file2' -> 'dir2/dir1/file2'"
"'dir1/file3' -> 'dir2/dir1/file3'"
"'file7' -> 'dir2/file7'"
```

#### Changes
*Directory:*
```sh
drwxr-sr-x   - /home/maurice/tmp
drwxr-sr-x   - ├── dir1
.rw-r--r--   0 │   ├── file1
.rw-r--r--   0 │   ├── file2
.rw-r--r--   0 │   └── file3
drwxr-sr-x   - ├── dir2
drwxr-sr-x   - │   ├── dir1
.rw-r--r--   0 │   │   ├── file1
.rw-r--r--   0 │   │   ├── file2
.rw-r--r--   0 │   │   └── file3
.rw-r--r--   0 │   ├── file1
.rw-r--r--   0 │   ├── file2
.rw-r--r--   0 │   ├── file3
.rw-r--r--   0 │   ├── file4
.rw-r--r--   0 │   ├── file5
.rw-r--r-- 173 │   └── file7
.rw-r--r--   0 ├── file1
.rw-r--r--   0 ├── file2
.rw-r--r--   0 ├── file3
.rw-r--r--   0 ├── file4
.rw-r--r--   0 ├── file5
.rw-r--r-- 173 ├── file6
.rw-r--r-- 173 └── file7
```

### `.os.ln` - make links between files
*Directory:*
```sh
drwxr-sr-x - dir1
.rw-r--r-- 0 file1
```

```q
q).os.ln`file1`file2
2025.09.30D10:09:25.721403178 [SYSTEM]: ln -sfv file1 file2
"'file2' -> 'file1'"
q).os.ln`dir1`dir2
2025.09.30D10:09:42.200771305 [SYSTEM]: ln -sfv dir1 dir2
"'dir2' -> 'dir1'"
```

#### Changes
*Directory:*
```sh
drwxr-sr-x - dir1
lrwxrwxrwx - dir2 -> dir1
.rw-r--r-- 0 file1
lrwxrwxrwx - file2 -> file1
```

### TODO: Custom Functions
