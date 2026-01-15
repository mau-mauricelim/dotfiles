/#####################
/# Bitwise operation #
/#####################

.lib.require`codec

/ Bits right shift
/ @example - .bits.bitsRightShift[1;10100b]
/ bitsRightShift:.bits.bitsRightShift:xprev; / Slower
// WARN: The length is shorter (no padding), use xprev to get the same length
.bits.bitsRightShift:{neg[x]_y};

/ Bits left shift
/ @example - .bits.bitsLeftShift[1;1 0 1 0 0]
/ bitsLeftShift:.bits.bitsLeftShift:{neg[x]xprev y}; / Slower
// WARN: The length is longer, use xprev to get the same length
.bits.bitsLeftShift:{1=y,x#0b};

/ Decimal (Number base) right shift
/ @example - .bits.decRightShift[1;256]
.bits.decRightShift:{.codec.binToDec .bits.bitsRightShift[x].codec.decToBin y};

/ Decimal (Number base) left shift
/ @example - .bits.decLeftShift[1;256]
.bits.decLeftShift:{.codec.binToDec .bits.bitsLeftShift[x].codec.decToBin y};

/ Bitwise Inclusive OR
/ @example - .bits.bitsOr(1111011b;0101101b;0 0 0 0 1 1 0)
.bits.bitsOr:any;
/ @example - .bits.bitsXor(1111011b;0101101b;0 0 0 0 1 1 0)
/ Bitwise Exclusive OR (XOR)
.bits.bitsXor:.q.xor/;

/ Decimal (Number base) Bitwise Inclusive OR
/ @example - .bits.decBitsOr 123 45 6
.bits.decBitsOr:{.codec.binToDec .bits.bitsOr .codec.decToBin each x};
/ Decimal (Number base) Bitwise Exclusive OR (XOR)
/ @example - .bits.decBitsXor 123 45 6
.bits.decBitsXor:{.codec.binToDec .bits.bitsXor .codec.decToBin each x};
