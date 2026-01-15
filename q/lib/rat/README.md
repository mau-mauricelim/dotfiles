# SSH Key Fingerprint Random Art

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
q)/ Decode base64 > md5 hash
q)-1"MD5:",":"sv string md5`char$.Q.atobp"AAAAC3NzaC1lZDI1NTE5AAAAIEMyvfXRXvN071Vi3BNvmExalrlWEAJ2EMoJ04gTovrz";
MD5:28:dc:31:9e:b4:da:32:13:af:60:3d:46:98:df:2b:6b

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
```

Source code:
- https://github.com/openssh/openssh-portable/blob/master/sshkey.c
