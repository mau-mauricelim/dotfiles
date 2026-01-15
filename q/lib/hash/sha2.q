/#########
/# SHA-2 #
/#########

// NOTE: No performance benefit converting to an accumulator
.sha2.hash:{[ns;algo;text]
    (messageSize;blockSize;wordSize;K;sigma0;sigma1;Sigma0;Sigma1;bit):ns`messageSize`blockSize`wordSize`K`sigma0`sigma1`Sigma0`Sigma1`bit;
    (H;bit):ns[algo]`H`bit;
    bits:.sha.preprocess[messageSize;blockSize;wordSize;text];
    / 3.2 Operations on Words
    addMod2w:.sha.addMod2w wordSize;
    / 5.2 Parsing the Message
    blocks:blockSize cut bits;
    / Process each block
    j:0;
    do[count blocks;
        / Message schedule
        W,:(count[K]-count W:wordSize cut blocks j)#enlist wordSize#0b;
        / Extend the first 16 words into the remaining words
        do[count[W]-i:16;
            W[i]:addMod2w(W i-16;sigma0 W i-15;W i-7;sigma1 W i-2);
            i+:1];
        / Compression loop
        (a;b;c;d;e;f;g;h;i):H,0;
        do[count K;
            T1:addMod2w(h;Sigma1 e;.sha.Ch[e;f;g];K i;W i);
            T2:addMod2w(Sigma0 a;.sha.Maj[a;b;c]);
            (h;g;f;e;d;c;b;a):(g;f;e;addMod2w(d;T1);c;b;a;addMod2w(T1;T2));
            i+:1];
        / Update hash values
        H:addMod2w each flip((a;b;c;d;e;f;g;h);H);
        j+:1];
    / Concatenation of the hash values
    (bit div 4)#raze flip .codec.decToHex .codec.binToDec each H
    };
