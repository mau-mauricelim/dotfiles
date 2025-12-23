/##############
/# AOC helper #
/##############

/ Get a list of coordinates from a list of boolean list(s)
/ The coordinates are natural numbers, i.e. non-negative integers in (Y,X) format
/ 0 → +X
/ ↓
/+Y
/ @param x - list of boolean list(s)
getCoor:.aoc.getCoor:{raze{x,/:y}'[til count x;where each x]};

/ Get the movement coordinates for:
/ Chebyshev (☐) distance - clockwise from top left
cheby:.aoc.chebyshev:{[n] ((d cross d:n*-1+til 3)except enlist 2#0)0 1 2 4 7 6 5 3};
/ Orthogonal (+) distance - clockwise from top
ortho:.aoc.orthogonal:{[n] d where n=abs sum flip d:.aoc.chebyshev n};
/ Diagonal (X) distance - clockwise from top left
diagn:.aoc.diagonal:{[n] d where n<>abs sum flip d:.aoc.chebyshev n};
/ Manhatten (◇) distance - clockwise from top
manht:.aoc.manhatten:{[n] raze flip .aoc.orthogonal[n]-/:(til n)*\:.aoc.diagonal 1};

/ Split a list (of any type) into sublists
splitBy:.aoc.splitBy:{[list;split] get(list group@[sums differ excl;where excl:split~/:list;:;0N])_0N};
/ Split a list of strings into sublists on empty lines
/ @param x - list of strings
splitByEmptyStr:.aoc.splitByEmptyStr:.aoc.splitBy[;""];

/ Boundary fill
/ @param x - boolean grid (boundary 1b)
// WARN: Boundary has to be fully closed, including diagonals
bfill:.aoc.bfill:{x|min@[;1;flip]{1=mod[;2]sums@'x&1 rotate x}each(x;flip x)};

/ Neighbour sum 3 verticals - sum of verticals+middle
sum3v:.aoc.sum3v:{1_3 msum x,0*1#x};
/ Neighbour sum 9 - sum of adjacents+middle: sum 3 rows and transpose 2 times
sum9:.aoc.sum9:{2(flip .aoc.sum3v@)/x};
/ Neighbour sum 8 - sum 9-self
sum8:.aoc.sum8:{.aoc.sum9[x]-x};
/ Neighbour sum 5 - sum of orthogonals+middle: verticals+horizontals-middle(counted 2 times)
sum5:.aoc.sum5:{sum[@[;1;flip].aoc.sum3v each(x;flip x)]-x};
/ Neighbour sum 4 - sum 5-self
sum4:.aoc.sum4:{.aoc.sum5[x]-x};
/ Neighbour sum 5 diagonals
sum5d:.aoc.sum5d:{.aoc.sum9[x]-.aoc.sum4 x};
/ Neighbour sum 4 diagonals
sum4d:.aoc.sum4d:{.aoc.sum9[x]-.aoc.sum5 x};
