/################################
/# Time-based One-Time Password #
/################################

// TODO: Add tests

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
    "0"^neg[len]$string mod[dec;1000000]
    };

.totp.sha1:{.totp.i.totp[30;6;.hmac.sha1;.z.p;x]};
