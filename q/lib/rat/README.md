# 🐀 rat (Random art)

SSH Key Fingerprint Random Art

```sh
$ cat ~/.ssh/id_ed25519_tmp.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMyvfXRXvN071Vi3BNvmExalrlWEAJ2EMoJ04gTovrz username@hostname

$ ssh-keygen -lf ~/.ssh/id_ed25519_tmp
256 SHA256:yqx3EES2ZTrsDOIpsv7GlgcwDOmBGERuHGLAc+oijrg username@hostname (ED25519)

$ ssh-keygen -lvf ~/.ssh/id_ed25519_tmp
256 SHA256:yqx3EES2ZTrsDOIpsv7GlgcwDOmBGERuHGLAc+oijrg username@hostname (ED25519)
+--[ED25519 256]--+
|@B   .o o        |
|X+.. o.=         |
|++* ..=          |
|.B o +..         |
|+ =   o.S        |
|++ . o..         |
|B . o +.         |
|+. = o. .        |
|Eo+.o. .         |
+----[SHA256]-----+

$ ssh-keygen -lf ~/.ssh/id_ed25519_tmp -E md5
256 MD5:28:dc:31:9e:b4:da:32:13:af:60:3d:46:98:df:2b:6b username@hostname (ED25519)

$ ssh-keygen -lvf ~/.ssh/id_ed25519_tmp -E md5
256 MD5:28:dc:31:9e:b4:da:32:13:af:60:3d:46:98:df:2b:6b username@hostname (ED25519)
+--[ED25519 256]--+
|                 |
|                 |
|      +          |
|   + + *         |
|  o = * S        |
|   + B           |
|  o X +          |
| . oE* .         |
|   .oo.          |
+------[MD5]------+
```

## Usage examples

```q
q)/ Decode base64 > sha256 hash > encode base64
q)-1"SHA256:",{(x?"=")#x}.codec.hexToB64 .Q.sha256`char$.Q.atobp"AAAAC3NzaC1lZDI1NTE5AAAAIEMyvfXRXvN071Vi3BNvmExalrlWEAJ2EMoJ04gTovrz";
SHA256:yqx3EES2ZTrsDOIpsv7GlgcwDOmBGERuHGLAc+oijrg

q)-1 .rat.rat"yqx3EES2ZTrsDOIpsv7GlgcwDOmBGERuHGLAc+oijrg";
+-----------------+
|@B   .o o        |
|X+.. o.=         |
|++* ..=          |
|.B o +..         |
|+ =   o.S        |
|++ . o..         |
|B . o +.         |
|+. = o. .        |
|Eo+.o. .         |
+-----------------+

q)/ Decode base64 > md5 hash
q)-1"MD5:",":"sv .codec.byteToHex md5`char$.Q.atobp"AAAAC3NzaC1lZDI1NTE5AAAAIEMyvfXRXvN071Vi3BNvmExalrlWEAJ2EMoJ04gTovrz";
MD5:28:dc:31:9e:b4:da:32:13:af:60:3d:46:98:df:2b:6b

q).codec.hexToB64 raze .codec.byteToHex md5`char$.Q.atobp"AAAAC3NzaC1lZDI1NTE5AAAAIEMyvfXRXvN071Vi3BNvmExalrlWEAJ2EMoJ04gTovrz"
"KNwxnrTaMhOvYD1GmN8raw=="

q)-1 .rat.rat"KNwxnrTaMhOvYD1GmN8raw==";
+-----------------+
|                 |
|                 |
|      +          |
|   + + *         |
|  o = * S        |
|   + B           |
|  o X +          |
| . oE* .         |
|   .oo.          |
+-----------------+
```

## Visualizer

A visualizer can be created by using `scan` rather than `over`:
```q
path:{
    byte:.Q.atobp x;
    binary:(reverse 2 cut vs[0b]@)@'byte;
    dir:(00b;01b;11b;10b)!.aoc.diagonal 1;
    size:9 17;
    grid:.[size#0;start:size div 2;1+];
    move:raze dir binary;
    / Scan the path
    walk:{(p;.[x 1;p:z&0 0|y+x 0;1+])}[;;size-1]\[(start;grid);move];
    art:{[start;walk] .util.draw[" .o+=*BOX@%&#/^"walk 1;(start;walk 0);"SE"]}[start]'[walk];
    / Add the borders
    {[size;art] {y,x,y}["|",'art,'"|";enlist"+",(size[1]#"-"),"+"]}[size]'[art]};
walk:{.term.clear[]; -1 x; sleep 00:00:00.05}@'path@;
```

Run the visualizer:
```q
walk"yqx3EES2ZTrsDOIpsv7GlgcwDOmBGERuHGLAc+oijrg";
```

https://github.com/user-attachments/assets/2bad38cf-f93f-4c5c-b037-7c89563e3e3a

Source code:
- https://github.com/openssh/openssh-portable/blob/master/sshkey.c
