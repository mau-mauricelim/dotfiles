/#####################
/# Bitwise operation #
/#####################

/ Binary from integer
intToBin:.bits.intToBin:vs[0b];
/ Integer from binary
binToInt:.bits.binToInt:{2 sv`long$x};
/ Right shift - OR neg[y]xprev binary
rightShift:.bits.rightShift:{.bits.binToInt neg[y]_.bits.intToBin x};
/ Left shift - OR y xprev binary
leftShift:.bits.leftShift:{.bits.binToInt .bits.intToBin[x],y#0b};
/ Bitwise Inclusive OR
inclusiveOr:.bits.inclusiveOr:{.bits.binToInt any .bits.intToBin each x};
/ Bitwise Exclusive OR (XOR)
exclusiveOr:.bits.exclusiveOr:{.bits.binToInt(.q.xor/).bits.intToBin each x};
