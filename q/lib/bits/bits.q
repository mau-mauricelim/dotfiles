/#####################
/# Bitwise operation #
/#####################

/ Number to bits/binary (boolean)
/ @example - .bits.numToBits 20
// NOTE: floor is faster than `long$
numToBits:.bits.numToBits:0b vs floor@;
numToBits64:.bits.numToBits64:0b vs`long$;
// NOTE: Casting to int/short is inaccurate
numToBits32:.bits.numToBits32:-32#.bits.numToBits64@;
numToBits16:.bits.numToBits16:-16#.bits.numToBits64@;

/ Byte (Hexadecimal) to bits/binary (boolean)
// NOTE: Each char is 8-bits long
/ @example - .bits.byteToBits 0x68656c6c6f
byteToBits:.bits.byteToBits:0b vs';
byteToBitsFlat:.bits.byteToBitsFlat:raze .bits.byteToBits@;
/ Text to bits/binary (boolean)
/ @example - .bits.textToBits"hello"
textToBits:.bits.textToBits:.bits.byteToBits;
textToBitsFlat:.bits.textToBitsFlat:.bits.byteToBitsFlat;

/ Number to hexadecimal
/ @example - .bits.numToHex 10 12 19 1 28 100
numToHex:.bits.numToHex:flip .Q.hex 16 vs(),;
/ @example - .bits.hexToNum("0A";"0C";"13";"01";"1C";"64")
/            .bits.hexToNum"0A0C13011C64"
hexToNum:.bits.hexToNum:16 sv'.Q.hex?string upper(),`$;

// TODO: Hex to base64
/ hex <-> bytes <-> base64
hexToB64Byte:.bits.hexToB64Byte:{(neg sum"="=x)_raze 5_'0x0 vs'64 sv'0N 4#.Q.b6?x};
hexToB64:.bits.hexToB64:raze string .bits.hexToB64Byte@;

/ Bits/binary (boolean) to number
/ @example - .bits.bitsToNum 10100b
/            .bits.bitsToNum 1 0 1 0 0
bitsToNum:.bits.bitsToNum:2 sv;

/ Bits right shift
/ @example - .bits.bitsRightShift[1;10100b]
/ bitsRightShift:.bits.bitsRightShift:xprev; / Slower
// WARN: The length is shorter (no padding), use xprev to get the same length
bitsRightShift:.bits.bitsRightShift:{neg[x]_y};

/ Bits left shift
/ @example - .bits.bitsLeftShift[1;1 0 1 0 0]
/ bitsLeftShift:.bits.bitsLeftShift:{neg[x]xprev y}; / Slower
// WARN: The length is longer, use xprev to get the same length
bitsLeftShift:.bits.bitsLeftShift:{1=y,x#0b};

/ Number right shift
/ @example - .bits.numRightShift[1;256]
numRightShift:.bits.numRightShift:{.bits.bitsToNum .bits.bitsRightShift[x].bits.numToBits y};

/ Number left shift
/ @example - .bits.numLeftShift[1;256]
numLeftShift:.bits.numLeftShift:{.bits.bitsToNum .bits.bitsLeftShift[x].bits.numToBits y};

/ Bitwise Inclusive OR
/ @example - .bits.bitsOr(1111011b;0101101b;0 0 0 0 1 1 0)
bitsOr:.bits.bitsOr:any;
/ @example - .bits.bitsXor(1111011b;0101101b;0 0 0 0 1 1 0)
/ Bitwise Exclusive OR (XOR)
bitsXor:.bits.bitsXor:.q.xor/;

/ Number Bitwise Inclusive OR
/ @example - .bits.numBitsOr 123 45 6
numBitsOr:.bits.numBitsOr:{.bits.bitsToNum .bits.bitsOr .bits.numToBits each x};
/ Number Bitwise Exclusive OR (XOR)
/ @example - .bits.numBitsXor 123 45 6
numBitsXor:.bits.numBitsXor:{.bits.bitsToNum .bits.bitsXor .bits.numToBits each x};
