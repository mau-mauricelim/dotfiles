/############
/# Matrices #
/############

// INFO: https://nsl.com/misc/im.pdf
// INFO: https://code.kx.com/phrases/matrix/

/ Identity Matrix
.mats.id:{i=/:i:til x};
/ Graded Identity Matrix - indices necessary for performing a stable sort of an identity matrix
/ All the elements in this matrix are permutations of til x,
/ and they are useful as an intermediate step in generating all possible permutations of til x
.mats.gid:{idesc each .mats.id x};
/ Permutation Indices
permix:.mats.permix:{$[2>x;x#enlist 0;raze .mats.gid[x]@\:0,'1+.z.s x-1]};
/ Distinct Permutations
perm:.mats.perm:{distinct x .mats.permix count x};

/ Upper and Lower Triangular Matrix (excluding the diagonal)
.mats.triupp:{i<\:i:til x};
.mats.trilow:{i>\:i:til x};
/ These comparisons can be logically inverted if we want to generate matrices that include the diagonal
.mats.triuppd:not .mats.trilow@;
.mats.trilowd:not .mats.triupp@;

/ Anti-diagonal Sum - Toeplitz Index
.mats.adsum:{i+\:i:til x};
/ Anti-diagonal Modulo
.mats.admod:{.mats.adsum[x]mod x};
/ Main Diagonal Sum - Reverse Toeplitz Index
.mats.dsum:reverse .mats.adsum@;
/ Main Diagonal Sum - Reverse Toeplitz Index
.mats.dmod:reverse .mats.admod@;

/ "Nested Arrowheads" using bitwise-and and bitwise-or - Max and Min Coordinate Matrix
.mats.maxCoor:{i|\:i:til x};
.mats.minCoor:{i&\:i:til x};

/ Diagonal Matrix from Vector
.mats.dv:{x*'.mats.id count x};
