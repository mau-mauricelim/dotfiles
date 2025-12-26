# SSH Key Fingerprint Random Art

Example `ssh-keygen` output:
```sh
The key fingerprint is:
SHA256:DJNRlI5GWkl9Whe4B7/7bOn0irwZVu/gZzMGnj8L+30 username@hostname
The key's randomart image is:
+--[ED25519 256]--+
|     .o=o. ...   |
|      +oo = .    |
|     ++o + =     |
|    . o+o . o    |
|     .  S  . ..  |
|            .o . |
|            +o=..|
|           o.X=OE|
|            =*XBX|
+----[SHA256]-----+

The key fingerprint is:
SHA256:SIvkVKMBxEmrvI/kM/sQ2p8L79PlDQnexh1RiG4zxyk username@hostname
The key's randomart image is:
+---[RSA 3072]----+
| ++o. o  . o.    |
|  o. + .. o      |
|  . + .. . o     |
|.. + o.oE =      |
|.o  o.o=SB .     |
|..o   . B .      |
|.+o  . + o       |
|oo++... . .      |
| +=+*o           |
+----[SHA256]-----+
```

`ssh-keygen -lv -f output_keyfile` can also be used to print a SSH key fingerprint and random art

## Usage examples

```q
q).rat.rat"DJNRlI5GWkl9Whe4B7/7bOn0irwZVu/gZzMGnj8L+30"
"+-----------------+"
"|     .o=o. ...   |"
"|      +oo = .    |"
"|     ++o + =     |"
"|    . o+o . o    |"
"|     .  S  . ..  |"
"|            .o . |"
"|            +o=..|"
"|           o.XEO=|"
"|            =*XBX|"
"+-----------------+"
q).rat.rat"SIvkVKMBxEmrvI/kM/sQ2p8L79PlDQnexh1RiG4zxyk"
"+-----------------+"
"| ++o. o  . o.    |"
"|  o. + .. o      |"
"|  . + .. . o     |"
"|.. + o.oE =      |"
"|.o  o.o=SB .     |"
"|..o   . B .      |"
"|.+o  . + o       |"
"|oo++... . .      |"
"| +=+*o           |"
"+-----------------+"
```

Source code:
- https://github.com/openssh/openssh-portable/blob/master/sshkey.c
