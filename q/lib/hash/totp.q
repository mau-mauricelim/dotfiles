/################################
/# Time-based One-Time Password #
/################################

/ @param algo - function - hash function
/ @param step - number - time step in seconds
/ @param len - number - OTP length
/ @param k - string - base32 encoded text
/ @param t - timestamp
/ @return - string - digits of length (len)
.totp.i.totp:{[algo;step;len;k;t]
    / Base32 decode key
    k:.codec.b32ToByte k;
    / Time step calculation
    time:floor .util.unixTimeStamp[t]%step;
    / 8-Byte Big-Endian message
    msg:.codec.decToByte8 time;
    / Hash
    hash:algo[k;msg];
    / Dynamic truncation
    offset:.codec.binToDec 00001111b&.codec.byteToBin last hash;
    slice:hash offset+til 4;
    / Strip the Most Significant Bit
    dec:.codec.binToDec raze(01111111b;11111111b;11111111b;11111111b)&.codec.byteToBin slice;
    "0"^neg[len]$string mod[dec;"j"$10 xexp len]
    };

.totp.totp:{[algo;step;len;k] .totp.i.totp[.hmac algo;step;len;k;.z.p]};
.totp.md5:.totp.totp`md5;
.totp.sha1:.totp.totp`sha1;
.totp.sha224:.totp.totp`sha224;
.totp.sha256:.totp.totp`sha256;
.totp.sha384:.totp.totp`sha384;
.totp.sha512:.totp.totp`sha512;
.totp.sha512x224:.totp.totp`sha512x224;
.totp.sha512x256:.totp.totp`sha512x256;

/ Run TOTP Authenticator
/ @param x - string - base32 encoded text
/ @example - .totp.i.run[`sha1;30;6;"JBSWY3DPEHPK3PXP"]
.totp.i.run:{[algo;step;len;k]
    .lib.require`term`misc`qnix`colors;
    -1 .colors.wrap[`dim;`red;`default;"Press Ctrl+C to stop"];
    .[{[algo;step;len;k]
        totp:.totp.i.totp[.hmac algo;step;len;k];
        / Hide cursor
        1"\033[?25l";
        while[1b;
            seconds:.util.unixTimeStamp t:.z.p;
            elapsed:1+seconds mod step;
            (otp;nextOtp):totp each t+`second$0,step;
            out :.colors.wrap[`;`cyan;`default;string t]," ";
            out,:.colors.wrap[`;`blue;`default;]
                ssr[.pacman.i.progress[0b;elapsed;step;step];"[cC]";
                    {.colors.ansi[`;`yellow;`default],x,.colors.ansi[`;`blue;`default]}]," ";
            out,:.colors.wrap[`inverse`bold;`green;`default;"[OTP: ",otp,"]"]," ";
            .term.clearLine[];
            1 out,.colors.wrap[`dim;`white;`default;"[NEXT: ",nextOtp,"]"];
            .qnix.sleep 00:00:01;
            ];
        / Unhide cursor
        };(algo;step;len;k);{1"\033[?25h";$[x~"stop";-1"";'x]}];
    };

.totp.run.md5:.totp.i.run`md5;
.totp.run.sha1:.totp.i.run`sha1;
.totp.run.sha224:.totp.i.run`sha224;
.totp.run.sha256:.totp.i.run`sha256;
.totp.run.sha384:.totp.i.run`sha384;
.totp.run.sha512:.totp.i.run`sha512;
.totp.run.sha512x224:.totp.i.run`sha512x224;
.totp.run.sha512x256:.totp.i.run`sha512x256;
