bits32:-32#.bits.intToBin floor@;
constants:bits32 each(mod32:2 xexp 32)*{x-floor x}@;
hc:constants sqrt .maths.primes 19;
kc:constants xexp[;1%3] .maths.primes 311;

x:"hello world";
x1:(raze 0b vs'"x"$x),1b;
x448:x1,(((512-64)-count[x1]mod 512)mod 512)#0b;
x512:512 cut x448,0b vs 8*count x;

j:0;
do[count x512;
    w,:(64-count w:32 cut x512 j)#enlist 32#0b;
    sum32:bits32 mod[;mod32]sum 2 sv';
    i:16;
    do[48;
        s0:{(xor/)(-7 rotate x;-18 rotate x;3 xprev x)}w i-15;
        s1:{(xor/)(-17 rotate x;-19 rotate x;10 xprev x)}w i-2;
        w[i]:sum32(w i-16;s0;w i-7;s1);
        i+:1];
    i:0;
    (a;b;c;d;e;f;g;h):hc;
    do[64;
        S1:(xor/) -6 -11 -25 rotate\:e;
        ch:(e&f)xor g&not e;
        temp1:sum32(h;S1;ch;kc i;w i);
        S0:(xor/) -2 -13 -22 rotate\:a;
        maj:(xor/)(a&b;a&c;b&c);
        temp2:sum32(S0;maj);
        (h;g;f;e;d;c;b;a):(g;f;e;sum32(d;temp1);c;b;a;sum32(temp1;temp2));
        i+:1];
    hc:sum32 each flip((a;b;c;d;e;f;g;h);hc);
    j+:1];

raze flip .Q.hex 16 vs 0b sv'hc
