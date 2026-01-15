/##############
/# Random Art #
/##############

// INFO: https://github.com/openssh/openssh-portable/blob/master/sshkey.c
/ Draw an ASCII-Art representing the fingerprint
/ @param x - base64 encoded string (fingerprint)
/ @example - .rat.rat"yqx3EES2ZTrsDOIpsv7GlgcwDOmBGERuHGLAc+oijrg"
rat:.rat.rat:{
    byte:.Q.atobp x;
    binary:(reverse 2 cut vs[0b]@)@'byte;
    dir:(00b;01b;11b;10b)!.aoc.diagonal 1;
    char:" .o+=*BOX@%&#/^";
    size:9 17;
    grid:.[size#0;start:size div 2;1+];
    move:raze dir binary;
    walk:(-1+count char)&{(p;.[x 1;p:z&0 0|y+x 0;1+])}[;;size-1]/[(start;grid);move];
    art:.util.draw[char walk 1;(start;walk 0);"SE"];
    / Add the borders
    {y,x,y}["|",'art,'"|";enlist"+",(size[1]#"-"),"+"]};
