/#################
/# Encode/Decode #
/#################

// INFO https://code.kx.com/phrases/cast/

// Decimal (Number base) to/from Digit
.codec.decToDigit:10 vs;
.codec.digitToDec:10 sv;

// Decimal (Number base) to/from Binary
/ Variable-length
/ Based on decimal type
.codec.decToBin:0b vs;
/ Based on lowest number of bits required
.codec.decToBinB2:1=2 vs;
/ Fixed-length
.codec.decToBin64:.codec.decToBin`long$;
.codec.decToBinX:{$[x<c:count b:.codec.decToBinB2 floor y;'string[c]," bits required";((x-c)#0b),b]};
.codec.decToBin32:{.codec.decToBinX[32]x};
.codec.decToBin16:{.codec.decToBinX[16]x};

.codec.binToDec:2 sv;

// Byte (Hexadecimal) to/from Hexadecimal string
.codec.byteToHex:string;
.codec.hexToByte:get"0x",;

// Decimal (Number base) to/from Hexadecimal string
.codec.decToHex:.Q.hex 16 vs;
.codec.hexToDec:16 sv .Q.hex?floor@;

// Byte (Hexadecimal) to/from Decimal (Number base)
/ Variable-length
.codec.byteToDec:{.codec.hexToDec raze .codec.byteToHex x};
.codec.decToByte:{.codec.hexToByte .codec.decToHex x};
/ Fixed-length
.codec.decToByte8:0x0 vs`long$;
.codec.decToByteX:{$[x<c:count b:.codec.decToByte y;'string[c]," bytes required";((x-c)#0x0),b]};
.codec.decToByte4:{.codec.decToByteX[4]x};
.codec.decToByte2:{.codec.decToByteX[2]x};

// Binary to/from Hexadecimal string
.codec.binToHex:{.codec.decToHex .codec.binToDec x};
/ Variable-length
.codec.hexToBin:{.codec.decToBinB2 .codec.hexToDec x};
/ Fixed-length
.codec.hexToBin64:{.codec.decToBin64 .codec.hexToDec x};
.codec.hexToBin32:{.codec.decToBin32 .codec.hexToDec x};
.codec.hexToBin16:{.codec.decToBin16 .codec.hexToDec x};

// Binary to/from Byte (Hexadecimal) &
// Binary to/from Text
.codec.binToByte:{.codec.decToByte .codec.binToDec x};
.codec.binToText:{`char$.codec.binToDec x};
/ Fixed-length
.codec.byteToBin64:.codec.textToBin64:{.codec.decToBin64 each x};
.codec.byteToBin32:.codec.textToBin32:{.codec.decToBin32 each x};
.codec.byteToBin16:.codec.textToBin16:{.codec.decToBin16 each x};
.codec.byteToBin:.codec.textToBin:.codec.byteToBin8:.codec.textToBin8:{.codec.decToBin each x};

// Text to/from Decimal (Number base) &
// Text to/from Byte (Hexadecimal)
.codec.textToDec:`long$;
.codec.textToByte:`byte$;
.codec.byteToText:.codec.decToText:`char$;

// Text to/from Hexadecimal string
.codec.textToHex:{string .codec.textToByte x};
.codec.hexToText:{.codec.byteToText .codec.hexToByte x};

// Hexadecimal string to/from Base64 string
.codec.hexToB64:{.Q.btoa .codec.hexToText x};
.codec.b64ToHex:{raze .codec.byteToHex .Q.atobp x};
