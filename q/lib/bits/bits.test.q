if[not all(0000000000000000000000000000000000000000000000000000000000010100b~`.bits.intToBin 20;
    20 20~`.bits.binToInt@'(10100b;1 0 1 0 0);
    512~`.bits.leftShift[256;1];
    128~`.bits.rightShift[256;1];
    127~`.bits.inclusiveOr 123 45 6;
    80~`.bits.exclusiveOr 123 45 6);
    '"Bitwise operation functions failed!"];

.test.passed 0b;
