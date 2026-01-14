/#########################
/# Secure Hash Algorithm #
/#########################

// INFO: https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf

/ 3.2 Operations on Words
.sha.addMod2w:{.codec.decToBinX[x]mod[;2 xexp x].codec.binToDec sum y};

/ 4.1 Functions
.sha.Ch:{.q.xor[x&y;z&not x]};
.sha.Maj:{(.q.xor/)(x&y;x&z;y&z)};
.sha.SigmaN:{(.q.xor/)x rotate\:y};
.sha.sigmaN:{(.q.xor/)((rotate;rotate;xprev)@'x)@\:y};

/ 5. PREPROCESSING
/ Message length is padded to a multiple of block size (512 or 1024 bits)
.sha.preprocess:{[messageSize;blockSize;wordSize;x]
    / 5.1 Padding the Message
    / Convert message to bits and append the bit "1" to the end of the message
    bits:(raze .codec.byteToBin x),1b;
    / Pad with 0 bits, less message size bits (64 or 128 bits)
    bits,:(((blockSize-messageSize)-count[bits]mod blockSize)mod blockSize)#0b;
    / Then append the message size bits that is equal to the number expressed using a binary representation
    bits,.codec.decToBinX[messageSize]8*count x};
