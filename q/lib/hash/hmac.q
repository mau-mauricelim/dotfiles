/##########################################
/# Hash-based Message Authentication Code #
/##########################################

// TODO: Add more algo e.g. sha256

/ @param k - byte - key
/ @param msg - byte - message
/ @return - byte
/ @example - .hmac.sha1[0x01;0x68656c6c6f]
.hmac.sha1:{[k;msg]
    k,:();
    size:64;
    if[size<count k;k:.Q.sha1 k];
    k,:(size-count k)#0x0;
    hash:{.codec.hexToByte raze"0"^-2$flip .codec.binToHex flip .bits.bitsXor .codec.byteToBin each(x;z#y)}[k;;size];
    ikey:hash 0x36;
    okey:hash 0x5C;
    ihash:.Q.sha1 ikey,msg;
    .Q.sha1 okey,ihash};
