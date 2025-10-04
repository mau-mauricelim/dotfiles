/####################
/# q unix-like util #
/####################

// INFO: https://code.kx.com/q/ref/sublist/#head-or-tail
.head.i.head:{[isHead;x]
    @[get;`.head.n;{.head.n:10}]; / Set default value here
    n:$[isHead;;neg].head.n;
    / If input is (::) or atomic number, return unary function: x sublist
    $[101h~typ:type x;n sublist;
        typ in neg 5 6 7h;($[isHead;;neg]x)sublist;
        n sublist x]};
head:.head.head:.head.i.head 1b;
tail:.head.tail:.head.i.head 0b;

/ Grep util
/ @param smart - boolean - 1b for smart-case
/ @param pat - sym/string - pattern to search for
/ @param inp - string list - input text
.grep.i.grep:{[smart;pat;inp]
    pat:.util.ensureStr pat;
    allLower:all pat in .Q.a;
    if[not"*"in pat;pat:"*",pat,"*"];
    inp where($[smart&allLower;lower;]inp)like pat};
/ Case sensitive search
grep:.grep.grep:.grep.i.grep 0b;
/ Smart-case: if pattern is all lower case, search is case insensitive
greps:.grep.greps:.grep.i.grep 1b;
/ Exact word match
grepw:.grep.grepw:{[pat;inp]
    pat:.util.ensureStr pat;
    inp where{[pat;line]any pat~/:" "vs?[lower[line]in .Q.a;line;" "]}[pat]each inp};

/ List directory contents
ls:.ls.ls:{
    {[path;lsDir]
        dirStr:.Q.s1 dir:$[path in(::;`);`:.;hsym`$.util.strPath path];
        if[not .util.exists dir;:-2(dirStr,": ",.error.fileNotFound;"")];
        if[lsDir;-1 dirStr,":"];
        -1(.Q.s1 key dir;"");
        }[;1<count x]each x;};
/ @return - dict
ls2:.ls.lsReturnDict:{(!). flip
    {[path]
        dir:$[path in(::;`);`:.;hsym`$.util.strPath path];
        entries:$[.util.exists dir;`#key dir;`$.error.fileNotFound];
        (dir;entries)
        }peach distinct(),x};

/ @return - sym - filepath
touch:{hclose hopen x:.q.Hsym .util.strPath x;x}';
