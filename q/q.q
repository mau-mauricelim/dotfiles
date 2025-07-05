/########
/# Core #
/########

P:0N!;
PC:{-1 x;};
reorder:xcols;
rename:xcol;

/ @param n - default number to take
/ @param x
/ - if x is (::), returns a function that takes the first N (lesser of 100 or count of data) entries of given data
/ - if x is a +N, returns a function that takes the first N (lesser of   x or count of data) entries of given data
/ - if x is a -N, returns a function that takes the last  N (lesser of   x or count of data) entries of given data
/ - else,         returns a result of first N (lesser of 100 or count of data) entries of x
/ @example
/ - head til 200
/ - head[10]til 200
/ - head[-10]til 200
head:{[n;x]
    f:{(signum[x]*abs[x]&count y)#y};
    $[101h~typ:type x;f n;
        typ in neg 5 6 7 8h;f x;
        f[n;x]]}100; / Default

// TODO: Create a tail util opposite of head

/ Special characters on the keyboard
.Q.sc:"~`!@#$%^&*()_-+={[}]|\\:;\"'<,>.?/";
/ Delete variable from namespace
vdel:{![$[1=count v;`.;` sv -1_v];();0b;(),last v:` vs x]};
/ Delete all variables from namespace. Namespaces cannot be deleted once it is created.
vdels:{![x;();0b;`symbol$()]};
/ Frecency of all chars
fcy:desc count each group raze read0@;
/ Frecency of all special chars
fcys:desc .Q.sc#fcy@;
sys:{1"system: ";PC x;system x};
exceptNulls:{$[0>type x;'list;x where not null x]};
/ List directory contents
ls:{
    {[path;lsDir]
        dirStr:.Q.s1 dir:$[path in(::;`);`:.;hsym`$np sp path];
        if[not exists dir;:-1(dirStr,": \"ERROR: No such file or directory\"";"")];
        if[lsDir;PC dirStr,":"];
        -1(.Q.s1 key dir;"");
        }[;1<count x]each x;};
/ @return - dict
ls2:{(!). flip
    {[path]
        dir:$[path in(::;`);`:.;hsym`$np sp path];
        entries:$[exists dir;`#key dir;`$"\"ERROR: No such file or directory\""];
        (dir;entries)
        }peach distinct(),x};

/ TP Log
truncate:{[tplog] if[7h~type chunk:-11!(-2;tplog);sys"truncate ",sp[tplog]," --size=",string last chunk]};
/ Replay tplog from n-th index
/ @param - tplog - same params as -11!
replay:{[index;tplog]
    index|:.u.i:0;
    oldUpd:upd;
    if[index<>.u.i;
        `upd set{[tab;data;index;oldUpd]
            if[index~.u.i;`upd set oldUpd];
            .u.i+:1}[;;index-1;oldUpd];
        ];
    res:-11!tplog;
    `upd set oldUpd;
    res};

/ Normalize path
np:ssr[;"//";"/"]over ssr[;"\\";"/"]@;
/ String path
sp:{np(":"~first x)_x:raze string x};
/ https://code.kx.com/q/ref/hdel/#hdel
/ Recursive dir listing
diR:{$[11h=type d:key x;raze x,.z.s each` sv/:x,/:d;d]};
/ rm -rf
nuke:hdel each desc diR@; / desc sort
/ Fuzzy search namespace objects - case and order insensitive
/ @global - creates a cache (dict)
/ @param - pat - sym (list)
/ NOTE: add a null sym to regenerate cache
/ @example - fzf`search`pattern
/ @return - sym list
fzf:{[pat]
    if[(any null pat)|not exists`.fzf.cache;
        obj@:where -11h=type each obj:1_diR`;
        obj,:last each` vs'1_diR`.;
        .fzf.cache:obj!lower string .Q.id peach obj];
    pat:{"*",x,"*"}each lower string exceptNulls(),pat;
    where{all y like/:x}[pat]peach .fzf.cache
    };
/ @return - table of objects and its values
fzfv:{[pat]([]obj;val:value each obj:fzf pat)};
/ @return - table of objects and its approximate memory usage
fzfm:{[pat] delete val from update human:hb peach size from update size:{-22!x}peach val from fzfv pat};
/ Get the object name of the value
/ @example - q))whoami .z.s
whoami:{t:fzfv`;exec obj from t where val~'x};

/ https://code.kx.com/q/basics/funsql/#the-solution
/ Better `parse` function
PARSE:{
    system"c 30 200";
    / Replace k representation with equivalent q keyword
    funcK:{
        kreplace:{[x] $[`=qval:.q?x;x;"~~",string[qval],"~~"]};
        $[0=t:type x;.z.s each x;t<100h;x;kreplace x]
        };
    / Replace eg ,`FD`ABC`DEF with "enlist`FD`ABC`DEF"
    funcEn:{
        ereplace:{"~~enlist",(.Q.s1 first x),"~~"};
        ereptest:{(1=count x) and ((0=type x) and 11=type first x) or 11=type x};
        $[ereptest x;ereplace x;0=type x;.z.s each x;x]
        };
    tidy:{ssr/[;("\"~~";"~~\"");("";"")] $[","=first x;1_x;x]};
    basic:tidy .Q.s1 funcK funcEn ::;
    / Where clause needs to be a list of Where clauses,
    / so if only one Where clause, need to enlist.
    stringify:{[x;basic] $[(0=type x) and 1=count x;"enlist ";""],basic x}[;basic];
    / If a dictionary, apply to both keys and values
    ab:{[x;stringify]
        addbraks:{"(",x,")"};
        $[(0=count x) or -1=type x; .Q.s1 x;
            99=type x; (addbraks stringify key x ),"!",stringify value x;
            stringify x]
        }[;stringify];
    inner:{[x;ab]
        idxs:2 3 4 5 6 inter ainds:til count x;
        x:@[x;idxs;'[ab;eval]];
        if[6 in idxs;x[6]:ssr/[;("hopen";"hclose");("iasc";"idesc")] x[6]];
        / For select statements within select statements
        x[1]:$[-11=type x 1;x 1;[idxs,:1;.z.s x 1]];
        x:@[x;ainds except idxs;string];
        strBrk:{y,(";" sv x),z};
        x[0],strBrk[1_x;"[";"]"]
        }[;ab];
    inner parse x};
/ Prints result to console and returns result
Parse:{PC res:PARSE x;res};

/ https://github.com/CillianReilly/qtools/blob/master/q.q
paste:{value{$[(""~r:read0 0)and not sum 124-7h$x inter"{}";x;x,` sv enlist r]}/[""]};
clear:{1"\033[H\033[J";};
resize:{system"c ",first system"stty size"};
full:{system"c 2000 2000"};

/draw:.[;;:;][;;]/[;];
draw:{[grid;coor;char] .[grid;coor;:;char]}[;;]/[;];
exists:{not()~key x};
isDir:11h~type key@;
// NOTE:`not isFile x` is not equivalent to `isDir x`!
isFile:{x~key x};
pad:{
    if[10h~type y;:x$y];
    padding:(0|abs[x]-count y)#(y,()) -1;
    x#$[x<0;padding,y;y,padding]
    };
/ Rotate grid by 90 degrees anti-clockwise
acw90:{reverse flip x};
cw90:{reverse each flip x};
randSeed:{system"S ",0N?string[.z.t]except":."};

/ https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#section-links
/ @param x - string
ghSecLink:{ssr[;" ";"-"]ssr[;"  ";" "]/[lower trim x]except .Q.sc except"-"};

/ Human-readable bytes in specified unit
hbu:{[bytes;unit]
    units:`$b,"KMGTPEZY",'b:"B";
    if[specified:not(::)~unit;
        if[null units offset:units?unit:upper unit;'"Unit not found in: ",-3!units]];
    power:0^floor(binary:1024)xlog bytes,:();
    size:bytes%binary xexp power;
    if[specified;size*:binary xexp power-offset];
    $[specified;,\:[;string unit];,'[;string units power]]string[size],'" "};
hb:hbu[;(::)];

/ Json merge tool
/ Merge jsons based on kdb type
jm:{f:key x;
    f@:where f like"*.json";
    f@:where not f like"merged_type*.json"
    if[not count f;:()];
    k:{.j.k read1 x}peach` sv'x,'f;
    j:.j.j peach k group type each k;
    {.Q.dd[x;`$"merged_type",y,".json"]0:enlist z}[x]'[string abs key j;value j]
    };

/##############
/# AOC helper #
/##############

/ Get a list of coordinates from a list of boolean list(s)
/ The coordinates are natural numbers, i.e. non-negative integers in (Y,X) format
/ 0 → +X
/ ↓
/+Y
/ @param x - list of boolean list(s)
getCoor:{raze{x,/:y}'[til count x;where each x]};

/ Get the movement coordinates for:
/ Chebyshev (☐) distance - clockwise from top left
cheby:{[n] ((d cross d:n*-1+til 3)except enlist 2#0)0 1 2 4 7 6 5 3};
/ Orthogonal (+) distance - clockwise from top
ortho:{[n;c] d where n=abs sum flip d:c n}[;cheby];
/ Diagonal (X) distance - clockwise from top left
diagn:{[n;c] d where n<>abs sum flip d:c n}[;cheby];
/ Manhatten (◇) distance - clockwise from top
manht:{[n;o;d1] raze flip o[n]-/:(til n)*\:d1}[;ortho;diagn 1];

/ Split a list (of any type) into sublists
splitBy:{[list;split] list@/:{x+til y-x}.'flip group[deltas not(list~\:split),1b]1 -1};
/ Split a list of strings into sublists on empty lines
/ @param x - list of strings
splitEmpty:splitBy[;""];

/#########
/# Maths #
/#########

/ Big product
/ @param numStrs - list of (big) number strings to be multiplied
.maths.bigPrd:{[numStrs;fast]
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

    trimZero:{[left;numStr] "0"^$[left;ltrim;rtrim]?["0"=numStr;" ";numStr]};
    / Always trim left
    numStr:trimZero[1b;raze string digitsPrd];
    if[not decimals;:numStr];
    / Make decimals
    numStr:(nd _numStr),".",(nd:neg decimals)#numStr;
    trimZero[0b;numStr]
    };
bprd:.maths.bigPrd[;1b];
bmprd:.maths.bigPrd[;0b];

/ Get all prime numbers up to N - using Sieve of Eratosthenes
/ https://stackoverflow.com/questions/71571704/finding-prime-numbers-kdb-discussion-about-projection-and-functions
/ sieve1 runs faster for smaller values of N, and only falls behind with N at a million or more
.maths.sieve1:{n:1+y?1b;(x,n;y and count[y]#10b where(n-1),1)}.;
.maths.sieve2:{n:1+y?1b;(x,n;@[y;1_-[;1]n*til 1+count[y]div n;:;0b])}.;
.maths.es:{[s;N]{x,1+where y}.({any z#y}[;;"j"$sqrt N].)s/(2;0b,1_N#10b)};
primes:{.maths.es[.maths$[x<1000000;`sieve1;`sieve2];x]};
/ Return only the prime factors (distinct of prime factorization)
primeFac:{
    / Optimization: to find all factors of a number, you only need to check up to its square root
    fac:2+til -1+floor sqrt x;
    / Actual factors
    fac@:where not x mod fac;
    / Corresponding co-factors
    fac,:x div fac;
    {x where 1=sum not x mod/:x}fac
    };
/ Prime factorization
primeFzn:{
    c:-1+{count div[;y]\[{not x mod y}[;y];x]}[x]'[p:primeFac x];
    raze c#'p
    };

/ Positive co-primes of that number which are less than that number
/ Generates (and removes) all multiples of the prime factors that are less than the number
coPrime:{til[x]except raze p*'til@'x div p:primeFac x};

/ Greatest common divisor using Euclidean algorithm
.maths.i.gcd:{$[y;.z.s[y;x mod y];x]};
gcd:.maths.i.gcd over;
/ Least common multiple
lcm:{y*x div .maths.i.gcd[x;y]}over;

/#####################
/# Bitwise operation #
/#####################

/ Binary from integer
bi:vs[0b];
/ Integer from binary
ib:{2 sv`long$x};
/ Right shift - OR neg[y]xprev binary
brs:{ib neg[y]_bi x};
/ Left shift - OR y xprev binary
bls:{ib bi[x],y#0b};
/ Bitwise Inclusive OR
bor:{ib any bi each x};
/ Bitwise Exclusive OR (XOR)
xor:<>;
bxor:{ib(xor/)bi each x};

/#########
/# Cache #
/#########

/ General function to cache a function for recursive calls
/ https://github.com/adotsch/aoc/blob/master/2023/cached.q
/ @example - cacheFn[`f;{[x;y] y*x xexp til 1000000}]
cacheFn:{[fnName;fn]
    if[-11h<>type fnName;'symbol];
    / Projection ("placeholder") for the input params - e.g. enlist[;][2;3]
    projection:({};{enlist x};(;);(;;);(;;;);(;;;;);(;;;;;);(;;;;;;);(;;;;;;;))valence fn;
    / General cached function
    cachedFn:{[cacheDict;fn;params]
        / Retrieve result from cache with serialized (-8!) input params
        if[not(::)~res:cacheDict byte:-8!params;:res];
        / Compute the result and add it to the cache
        @[cacheDict;byte;:;res:fn . params];
        res}[cacheInit fnName;fn];
    / (Re)defines original function with the composition of the cached function and projection
    / https://code.kx.com/q/ref/compose/
    fnName set(')[cachedFn;projection]
    };
/ (Re-)init cache (dict) for the function name
cacheInit:{[fnName] .Q.dd[`.cache;fnName]set(`g#enlist 0#0x0)!enlist{value}};

/ Valence (rank) of a function
/ https://code.kx.com/q/ref/value/#lambda
valence:{if[100h<>type x;'function]; count value[x]1};

/###########
/# Logging #
/###########

/ Plain text
.log.s:{$["\n"in msg;"\n",;]msg:$[10h=abs type x;;-1_.Q.s@]x};
.log.lvl:`INFO;
.log.lvls:`DEBUG`INFO`WARN`ERROR`BACKTRACE`FATAL`SYSTEM;
.log.colors:`magenta`cyan`red`red`yellow`red`green;
.log.log:{[lvl;msg]
    / Return msg if below current logging level
    if[(>). ll:.log.lvls?.log.lvl,lvl:upper lvl;:msg];
    if[.colors.enabled[];1 .colors.ansi`bold,.log.colors[last ll],`default];
    1 string[.z.p]," ";
    1"[",string[lvl],"]: ";
    -1$[.colors.enabled[];,[;.colors.reset[]];].log.s msg;
    if[`FATAL~lvl;exit 1];
    if[`SYSTEM~lvl;:system msg];
    };
/ Create functions .log.info, .log.warn etc.
{.Q.dd[`.log;lower x]set .log.log upper x}each .log.lvls;

/ https://code.kx.com/q/basics/debug/#trap
/ https://code.kx.com/q/ref/dotq/#trpd-extend-trap
/ @example - bt[{x+y};(1;`2)]
bt:{[f;args] .Q.trpd[f;args,();{[err;msg] .log.error err; .log.backtrace .Q.sbt msg}]};

banner:{[msg;qComment] side:"#"; $[qComment;"/",';](cover;side," ",msg," ",side;cover:(4+count msg)#side)};

/##########
/# Colors #
/##########

/ Select Graphic Rendition
.colors.sgr:{[style;fg;bg]
    s:`reset`bold`faint`italic`underline!til 5;
    c:`default`black`red`green`yellow`blue`magenta`cyan`white!39 30 31 32 33 34 35 36 37;
    (s;c;c+10)@'style,fg,bg
    }.;
.colors.ansi:{[style;fg;bg]
    n:";"sv string .colors.sgr style,fg,bg;
    csi:"\033[";
    csi,n,"m"
    }.;
.colors.reset:{@[value;`.colors.i.reset;{:.colors.i.reset:.colors.ansi`reset``}]};
.colors.enabled:{@[value;`.colors.i.enabled;{:.colors.i.enabled:"xterm-256color"~getenv`TERM}]};

/ List contents of directories/namespaces in a tree-like format
.tree.tree:{[path;maxDepth;dirFirst;showHidden]
    -1@1_string path;
    params:`path`prefix`maxDepth`dirFirst`showHidden`showColors!(path;"";maxDepth;dirFirst;showHidden;.colors.enabled[]);
    cnt:1b,.tree.branch params;
    -1("";", "sv(string 0^(count each group cnt)10b),'" ",'("directories";"files");"");
    };
.tree.branch:{[params]
    entries:(),key path:params`path;
    if[not params`showHidden;entries@:where not entries like".*"]; / Hide hidden files
    if[params`dirFirst;entries@:raze group[isFile peach .Q.dd[path]peach entries]01b];
    / Process each entry
    params[`maxDepth]-:1;
    raze{[params;entry;islast]
        typeD:isDir params[`path]:.Q.dd[params`path;entry];
        / The current branch would be in the following format:
        / "├── entry1"
        / "└── entryN"
        branch:$[islast;"\300";"\303"],"\304\304 ";
        / Print current entry (with colors)
        PC params[`prefix],branch,
            $[params`showColors;{.colors.ansi[`bold,(`yellow`cyan x),`default],y,.colors.reset[]}typeD;]string entry;
        / The next level would be in the following format:
        / "├── " becomes "│   "
        / "└── " becomes "    "
        / e.g. level1: "[    │   ├── ]level1"     OR "[    │   └── ]level1"
        /      level2: "[    │   │   ]├── level2"    "[    │       ]└── level2"
        params[`prefix],:$[islast;" ";"\263"],"   ";
        / Recursively process directories
        typeD,$[params[`maxDepth]&typeD;.tree.branch[params];()]
        }[params]'[entries;entries=last entries]
    };
/ If function is called with [], path defaults to current directory: `:.
tree:{[path] .tree.tree[;10;1b;0b]$[(::)~path;`:.;path]};
treea:{[path].tree.tree[;10;1b;1b]$[(::)~path;`:.;path]};

/#######
/# URI #
/#######
HEX:"0123456789ABCDEF";
.uri.chr:.Q.an,.Q.sc," ";
/ URI-encoding has reserved and unreserved characters set
/ But in this encoding map all characters are used
.uri.map:"%",'HEX 16 vs'.uri.chr!`int$.uri.chr;
.uri.enc:{raze((d!d:distinct x),y)x}[;.uri.map];
.uri.dec:{1_(value[y]!key y)"%",'"%"vs x}[;.uri.map];

/###########
/# Trivial #
/###########

/ CillianReilly
reflect:{x,1_reverse x};
/ Composing using :: instead of @ also gives some performance:
pyramid:reflect reflect each{x&/:x:1+til x}::;

/########
/# Docs #
/########

/ https://code.kx.com/q/ref/#command-line-options-and-system-commands
.docs.CL:(
    "file                                                         ";
    "\\a     tables                  \\r        rename            ";
    "-b     blocked                 -s \\s     secondary processes";
    "\\b \\B  views                   -S \\S     random seed      ";
    "-c \\c  console size            -t \\t     timer ticks       ";
    "-C \\C  HTTP size               \\ts       time and space    ";
    "\\cd    change directory        -T \\T     timeout           ";
    "\\d     directory               -u -U \\u  usr-pwd           ";
    "-e \\e  error traps             -u        disable syscmds    ";
    "-E \\E  TLS server mode         \\v        variables         ";
    "\\f     functions               -w \\w     memory            ";
    "-g \\g  garbage collection      -W \\W     week offset       ";
    "\\l     load file or directory  \\x        expunge           ";
    "-l -L  log sync                -z \\z     date format        ";
    "-o \\o  UTC offset              \\1 \\2     redirect         ";
    "-p \\p  listening port          \\_        hide q code       ";
    "-P \\P  display precision       \\         terminate         ";
    "-q     quiet mode              \\         toggle q/k         ";
    "-r \\r  replicate               \\\\        quit             ");

/ https://code.kx.com/q/basics/datatypes/#datatypes
/ https://code.kx.com/q4m3/2_Basic_Data_Types_Atoms/#20-overview
.docs.DT:(
    "Basic datatypes                                                            ";
    "n   c   name      sz  literal            null inf SQL                      ";
    "                                                                           ";
    "----------------------------------------------------------                 ";
    "0   *   list                                                               ";
    "1   b   boolean   1   0b                                                   ";
    "2   g   guid      16                     0Ng                               ";
    "4   x   byte      1   0x00                                                 ";
    "                                                                           ";
    "5   h   short     2   0h                 0Nh  0Wh smallint                 ";
    "6   i   int       4   0i                 0Ni  0Wi int                      ";
    "7   j   long      8   0j                 0Nj  0Wj bigint                   ";
    "                      0                  0N   0W                           ";
    "8   e   real      4   0e                 0Ne  0We real                     ";
    "9   f   float     8   0.0                0n   0w  float                    ";
    "                      0f                 0Nf                               ";
    "10  c   char      1   \" \"                \" \"                           ";
    "11  s   symbol        `                  `        varchar                  ";
    "12  p   timestamp 8   dateDtimespan      0Np  0Wp                          ";
    "13  m   month     4   2000.01m           0Nm  0Wm                          ";
    "14  d   date      4   2000.01.01         0Nd  0Wd date                     ";
    "15  z   datetime  8   dateTtime          0Nz  0wz timestamp                ";
    "16  n   timespan  8   00:00:00.000000000 0Nn  0Wn                          ";
    "17  u   minute    4   00:00              0Nu  0Wu                          ";
    "18  v   second    4   00:00:00           0Nv  0Wv                          ";
    "19  t   time      4   00:00:00.000       0Nt  0Wt time                     ";
    "                                                                           ";
    "Columns:                                                                   ";
    "n    short int returned by type and used for Cast, e.g. 9h$3               ";
    "c    character used lower-case for Cast and upper-case for Tok and Load CSV";
    "sz   size in bytes                                                         ";
    "inf  infinity (no math on temporal types); 0Wh is 32767h                   ";
    "                                                                           ";
    "RO: read only; RW: read-write                                              ";
    "                                                                           ";
    "Other datatypes                                                            ";
    "20-76   enums                                                              ";
    "77      anymap                                      104  projection        ";
    "78-96   77+t – mapped list of lists of type t       105  composition       ";
    "97      nested sym enum                             106  f'                ";
    "98      table                                       107  f/                ";
    "99      dictionary                                  108  f\\               ";
    "100     lambda                                      109  f':               ";
    "101     unary primitive                             110  f/:               ";
    "102     operator                                    111  f\\:              ";
    "103     iterator                                    112  dynamic load      ";
    "                                                                           ";
    "Above, f is an applicable value.                                           ";
    "Nested types are 77+t (e.g. 78 is boolean. 96 is time.)                    ";
    "The type is a short int:                                                   ";
    "- zero for a general list                                                  ";
    "- negative for atoms of basic datatypes                                    ";
    "- positive for everything else                                             ");

/ https://code.kx.com/q/ref/dotq/#the-q-namespace
.docs.DQ:(
    "General                           Datatype                                  ";
    " addmonths                         btoa        b64 encode                   ";
    " dd       join symbols             j10         encode binhex                ";
    " f        precision format         j12         encode base 36               ";
    " fc       parallel on cut          ty          type                         ";
    " ff       append columns           x10         decode binhex                ";
    " fmt      precision format         x12         decode base 36               ";
    " ft       apply simple                                                      ";
    " fu       apply unique            Database                                  ";
    " gc       garbage collect          chk         fill HDB                     ";
    " gz       GZip                     dpft dpfts  save table                   ";
    " id       sanitize                 dpt  dpts   save table unsorted          ";
    " qt       is table                 dsftg       load process save            ";
    " res      keywords                 en          enumerate varchar cols       ";
    " s        plain text               ens         enumerate against domain     ";
    " s1       string representation    fk          foreign key                  ";
    " sha1     SHA-1 encode             hdpf        save tables                  ";
    " V        table to dict            l           load                         ";
    " v        value                    ld          load and group               ";
    " view     subview                  li          load partitions              ";
    "                                   lo          load without                 ";
    " Constants                         M           chunk size                   ";
    " A a an   alphabets                qp          is partitioned               ";
    " b6       bicameral alphanums      qt          is table                     ";
    " n nA     nums & alphanums                                                  ";
    "                                  Partitioned database state                ";
    " Debug/Profile                     bv          build vp                     ";
    " bt       backtrace                bvi         build incremental vp         ";
    " prf0     code profiler            cn          count partitioned table      ";
    " sbt      string backtrace         D           partitions                   ";
    " trp      extend trap at           ind         partitioned index            ";
    " trpd     extend trap              MAP         maps partitions              ";
    " ts       time and space           par         locate partition             ";
    "                                   PD          partition locations          ";
    " Environment                       pd          modified partition locns     ";
    " K k      version                  pf          partition field              ";
    " w        memory stats             pn          partition counts             ";
    "                                   pt          partitioned tables           ";
    " Environment (Command-line)        PV          partition values             ";
    " def      command defaults         pv          modified partition values    ";
    " opt      command parameters       qp          is partitioned               ";
    " x        non-command parameters   vp          missing partitions           ";
    "                                                                            ";
    "IPC                               Segmented database state                  ";
    " addr     IP/host as int           P           segments                     ";
    " fps fpn  pipe streaming           u           date based                   ";
    " fs  fsn  file streaming                                                    ";
    " hg       HTTP get                File I/O                                  ";
    " host     IP to hostname           Cf          create empty nested char file";
    " hp       HTTP post                Xf          create file                  ");

/ https://code.kx.com/q/ref/dotz/#the-z-namespace
.docs.DZ:(
    "Environment                              Callbacks               ";
    " .z.a    IP address                       .z.bm    msg validator ";
    " .z.b    view dependencies                .z.exit  action on exit";
    " .z.c    cores                            .z.pc    close         ";
    " .z.f    file                             .z.pd    peach handles ";
    " .z.h    host                             .z.pg    get           ";
    " .z.i    PID                              .z.pi    input         ";
    " .z.K    version                          .z.po    open          ";
    " .z.k    release date                     .z.pq    qcon          ";
    " .z.l    license                          .z.r     blocked       ";
    " .z.o    OS version                       .z.ps    set           ";
    " .z.q    quiet mode                       .z.pw    validate user ";
    " .z.s    self                             .z.ts    timer         ";
    " .z.u    user ID                          .z.vs    value set     ";
    " .z.X/x  raw/parsed command line                                 ";
    "                                         Callbacks (HTTP)        ";
    "Environment (Compression/Encryption)      .z.ac    HTTP auth     ";
    " .z.zd   compression/encryption defaults  .z.ph    HTTP get      ";
    "                                          .z.pm    HTTP methods  ";
    "Environment (Connections)                 .z.pp    HTTP post     ";
    " .z.e    TLS connection status                                   ";
    " .z.H    active sockets                  Callbacks (WebSockets)  ";
    " .z.W/w  handles/handle                   .z.wc    WebSocket clos";
    "                                          .z.wo    WebSocket open";
    "Environment (Debug)                       .z.ws    WebSockets    ";
    " .z.ex   failed primitive                                        ";
    " .z.ey   arg to failed primitive                                 ";
    "                                                                 ";
    "Environment (Time/Date)                                          ";
    " .z.D/d  date shortcuts                                          ";
    " .z.N/n  local/UTC timespan                                      ";
    " .z.P/p  local/UTC timestamp                                     ";
    " .z.T/t  time shortcuts                                          ";
    " .z.Z/z  local/UTC datetime                                      ");

/ https://code.kx.com/q/basics/internal/#internal-functions
.docs.IF:(
    "0N!x        show                          Replaced:    ";
    "-4!x        tokens                        -1!   hsym   ";
    "-8!x        to bytes                      -2!   attr   ";
    "-9!x        from bytes                    -3!   .Q.s1  ";
    "-10!x       type enum                     -5!   parse  ";
    "-11!        streaming execute             -6!   eval   ";
    "-14!x       quote escape                  -7!   hcount ";
    "-16!x       ref count                     -12!  .Q.host";
    "-18!x       compress bytes                -13!  .Q.addr";
    "-21!x       compression/encryption stats  -15!  md5    ";
    "-22!x       uncompressed length           -19!  set    ";
    "-23!x       memory map                    -20!  .Q.gc  ";
    "-25!x       async broadcast               -24!  reval  ";
    "-26!x       SSL                           -29!  .j.k   ";
    "-27!(x;y)   format                        -31!  .j.jd  ";
    "-30!x       deferred response             -32!  .Q.btoa";
    "-33!x       SHA-1 hash                    -34!  .Q.ts  ";
    "-36!        load master key               -35!  .Q.gz  ";
    "-38!x       socket table                  -37!  .Q.prf0";
    "-120!x      memory domain                              ");

/ @global - `CL`DT`DQ`DZ`IF
/ The global functions print the docs to the console
{x set{x;PC y;}[;y]}.'flip(key;value)@\:.docs _`;
