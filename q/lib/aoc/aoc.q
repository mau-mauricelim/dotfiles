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
