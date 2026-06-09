/################################
/# Time-based One-Time Password #
/################################

/ @param step - number - time step in seconds
/ @param len - number - OTP length
/ @param algo - function - hash function
/ @param t - timestamp
/ @param k - string - base32 encoded text
/ @return - string - digits of length (len)
.totp.i.totp:{[step;len;algo;t;k]
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

.totp.sha1:{.totp.i.totp[30;6;.hmac.sha1;.z.p;x]};

/ Run TOTP Authenticator (HMAC-SHA1 30 seconds 6 digits)
/ @param x - string - base32 encoded text
/ @example - .totp.run.sha1"JBSWY3DPEHPK3PXP"
.totp.run.sha1:{
    .lib.require`term`misc`qnix;
    -1"Press Ctrl+C to stop";
    @[{
        totp:.totp.i.totp[step:30;6;.hmac.sha1;;x];
        sep:10#"";
        while[1b;
            seconds:.util.unixTimeStamp t:.z.p;
            elapsed:seconds mod step;
            .term.clearLine[];
            (otp;nextOtp):totp each t+`second$0,step;
            1"OTP: ",otp," ",.pacman.i.progress[0b;elapsed;step;step],sep,"[NEXT: ",nextOtp,"]";
            .qnix.sleep 00:00:01;
            ];
        };x;{$[x~"stop";-1"";'x]}];
    };
