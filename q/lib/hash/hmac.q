/##########################################
/# Hash-based Message Authentication Code #
/##########################################

/ @param k - byte/text - key
/ @param msg - byte/text - message
/ @param size - number - message size in bytes
/ @param algo - function - hash function
/ @return - byte
/ @example - .hmac.hmac[0x01;0x68656c6c6f;64;.Q.sha1]
.hmac.hmac:{[k;msg;size;algo]
    k:(),`byte$k;
    if[size<count k;k:algo k];
    k,:(size-count k)#0x0;
    hash:{.codec.hexToByte raze"0"^-2$flip .codec.binToHex flip .bits.bitsXor .codec.byteToBin each(x;z#y)}[k;;size];
    ikey:hash 0x36;
    okey:hash 0x5C;
    ihash:algo ikey,`byte$msg;
    algo okey,ihash};

.hmac.md5:{.hmac.hmac[x;y;64;{md5`char$x}]};

.hmac.sha1:{.hmac.hmac[x;y;64;.Q.sha1]};

.hmac.sha224:{.hmac.hmac[x;y;.sha2x32.messageSize;.Q.sha224]};
.hmac.sha256:{.hmac.hmac[x;y;.sha2x32.messageSize;.Q.sha256]};

.hmac.sha384:{.hmac.hmac[x;y;.sha2x64.messageSize;.Q.sha384]};
.hmac.sha512:{.hmac.hmac[x;y;.sha2x64.messageSize;.Q.sha512]};
.hmac.sha512x224:{.hmac.hmac[x;y;.sha2x64.messageSize;.Q.sha512x224]};
.hmac.sha512x256:{.hmac.hmac[x;y;.sha2x64.messageSize;.Q.sha512x256]};
