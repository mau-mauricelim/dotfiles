/#########
/# Maths #
/#########

/ Big product
/ @param numStrs - list of (big) number strings to be multiplied
.maths.i.bigPrd:{[numStrs;fast]
    funcPrd:$[fast;
        / Fast method - iterate while building an array of multiplicands (using */:) and sum and reduce to base 10
        / Handles digits up to 10^1000
        {(1_d,0)+x-10*d:x div 10}/;
        / Memory efficient method - shifting, multiplying and carrying values
        / Handles digits up to 10^1000000
        {r where 0<maxs r:{sum l,'c,'reverse l:#'[til count c:10 vs x;0]}/[x]}];

    decimals:sum{ss[reverse x;"."]0}each numStrs;
    numStrs:numStrs except\:".";
    digits:.Q.n?numStrs;

    digitsPrd:{[funcPrd;d1;d2]
        /partialPrd:{sum t,'(0,'x*/:y),'reverse t:til[count y]#'0};
        partialPrd:{{(x[0],0;0,x[1]+y*x[0])}/[(x;0&x);reverse y][1]};
        funcPrd partialPrd[d1;d2]
        }[funcPrd]/[digits];

    / Left trim zero
    numStr:.q.ltrimX["0";raze string digitsPrd];
    if[not decimals;:numStr];
    / Make decimals
    numStr:(nd _numStr),".",(nd:neg decimals)#numStr;
    .q.rtrimX["0";numStr]
    };
bprd:.maths.bigPrdFast:.maths.i.bigPrd[;1b];
.maths.bigPrdMem:.maths.i.bigPrd[;0b];

// INFO: https://stackoverflow.com/questions/71571704/finding-prime-numbers-kdb-discussion-about-projection-and-functions
/ Get all prime numbers up to N - using Sieve of Eratosthenes
/ sieve1 runs faster for smaller values of N, and only falls behind with N at a million or more
.maths.sieve1:{n:1+y?1b;(x,n;y and count[y]#10b where(n-1),1)}.;
.maths.sieve2:{n:1+y?1b;(x,n;@[y;1_-[;1]n*til 1+count[y]div n;:;0b])}.;
.maths.sieveE:{[s;N]{x,1+where y}.({any z#y}[;;"j"$sqrt N].)s/(2;0b,1_N#10b)};
primes:.maths.primes:{.maths.sieveE[;x]$[x<1000000;.maths.sieve1;.maths.sieve2]};
/ Return only the prime factors (distinct of prime factorization)
primeFac:.maths.primeFac:{
    / Optimization: to find all factors of a number, you only need to check up to its square root
    fac:2+til -1+floor sqrt x;
    / Actual factors
    fac@:where not x mod fac;
    / Corresponding co-factors
    fac,:x div fac;
    {x where 1=sum not x mod/:x}fac
    };
/ Prime factorization
primeFzn:.maths.primeFzn:{
    c:-1+{count div[;y]\[{not x mod y}[;y];x]}[x]'[p:.maths.primeFac x];
    raze c#'p
    };

/ Positive co-primes of that number which are less than that number
/ Generates (and removes) all multiples of the prime factors that are less than the number
coPrimes:.maths.coPrimes:{til[x]except raze p*'til@'x div p:.maths.primeFac x};

/ Greatest common divisor using Euclidean algorithm
.maths.i.gcd:{$[y;.z.s[y;x mod y];x]};
gcd:.maths.gcd:.maths.i.gcd over;
/ Least common multiple
lcm:.maths.lcm:{y*x div .maths.i.gcd[x;y]}over;
