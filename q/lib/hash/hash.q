numToBits32:-32#0b vs`long$;
byteToBits32:raze 0b vs';
mod32:mod[;2 xexp 32];
sum32:numToBits32 mod32 2 sv sum@;

/ Initial hash values (first 32-bits of the fractional parts of the square roots of first 8 primes)
H0:(0x6a09e667;0xbb67ae85;0x3c6ef372;0xa54ff53a;0x510e527f;0x9b05688c;0x1f83d9ab;0x5be0cd19);
/ Round constants (first 32-bits of the fractional parts of the cube roots of first 64 primes)
K :(0x428a2f98;0x71374491;0xb5c0fbcf;0xe9b5dba5;0x3956c25b;0x59f111f1;0x923f82a4;0xab1c5ed5);
K,:(0xd807aa98;0x12835b01;0x243185be;0x550c7dc3;0x72be5d74;0x80deb1fe;0x9bdc06a7;0xc19bf174);
K,:(0xe49b69c1;0xefbe4786;0x0fc19dc6;0x240ca1cc;0x2de92c6f;0x4a7484aa;0x5cb0a9dc;0x76f988da);
K,:(0x983e5152;0xa831c66d;0xb00327c8;0xbf597fc7;0xc6e00bf3;0xd5a79147;0x06ca6351;0x14292967);
K,:(0x27b70a85;0x2e1b2138;0x4d2c6dfc;0x53380d13;0x650a7354;0x766a0abb;0x81c2c92e;0x92722c85);
K,:(0xa2bfe8a1;0xa81a664b;0xc24b8b70;0xc76c51a3;0xd192e819;0xd6990624;0xf40e3585;0x106aa070);
K,:(0x19a4c116;0x1e376c08;0x2748774c;0x34b0bcb5;0x391c0cb3;0x4ed8aa4a;0x5b9cca4f;0x682e6ff3);
K,:(0x748f82ee;0x78a5636f;0x84c87814;0x8cc70208;0x90befffa;0xa4506ceb;0xbef9a3f7;0xc67178f2);
H0:byteToBits32 each H0;
K :byteToBits32 each K;

text:"hello world";
/ Convert text to binary and append a single 1
binary:(byteToBits32`byte$text),1b;
/ Pad with 0s until multiple of 512, less 64-bits (last block is 448-bits)
binary,:(((512-64)-count[binary]mod 512)mod 512)#0b;
/ Append 64-bits to the end, each char is 8-bits
/ Divide in 512-bits blocks
blocks:512 cut binary,:0b vs 8*count text;

j:0;
/ Process each 512-bits block
do[count blocks;
    / Message schedule (64 32-bits words)
    W,:(64-count W:32 cut blocks j)#enlist 32#0b;
    / Extend the first 16 words into the remaining 48 words
    i:16;
    do[48;
        sigma0:{(xor/)(-7 rotate x;-18 rotate x;3 xprev x)}W i-15;
        sigma1:{(xor/)(-17 rotate x;-19 rotate x;10 xprev x)}W i-2;
        W[i]:sum32(W i-16;sigma0;W i-7;sigma1);
        i+:1];
    / Compression loop
    i:0;
    (a;b;c;d;e;f;g;h):H0;
    do[64;
        Sigma1:(xor/) -6 -11 -25 rotate\:e;
        Ch:(e&f)xor g&not e;
        T1:sum32(h;Sigma1;Ch;K i;W i);
        Sigma0:(xor/) -2 -13 -22 rotate\:a;
        Maj:(xor/)(a&b;a&c;b&c);
        T2:sum32(Sigma0;Maj);
        (h;g;f;e;d;c;b;a):(g;f;e;sum32(d;T1);c;b;a;sum32(T1;T2));
        i+:1];
    / Update hash values
    H0:sum32 each flip((a;b;c;d;e;f;g;h);H0);
    j+:1];

raze flip .Q.hex 16 vs 0b sv'H0
