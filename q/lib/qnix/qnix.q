/####################
/# q unix-like util #
/####################

// INFO: https://code.kx.com/q/ref/sublist/#head-or-tail
.qnix.i.head:{[isHead;x]
    @[get;`.qnix.i.n;{.qnix.i.n:10}]; / Set default value here
    n:$[isHead;;neg].qnix.i.n;
    / If input is (::) or atomic number, return unary function: x sublist
    $[101h~typ:type x;n sublist;
        typ in neg 5 6 7h;($[isHead;;neg]x)sublist;
        n sublist x]};
head:.qnix.head:.qnix.i.head 1b;
tail:.qnix.tail:.qnix.i.head 0b;

/ Grep util
/ @param smart - boolean - 1b for smart-case
/ @param pat - sym/string - pattern to search for
/ @param inp - string list - input text
.qnix.i.grep:{[smart;pat;inp]
    pat:.util.ensureStr pat;
    allLower:all pat in .Q.a;
    if[not"*"in pat;pat:"*",pat,"*"];
    inp where($[smart&allLower;floor;]inp)like pat};
/ Case sensitive search
grep:.qnix.grep:.qnix.i.grep 0b;
/ Smart-case: if pattern is all lower case, search is case insensitive
greps:.qnix.greps:.qnix.i.grep 1b;
/ Exact word match
grepw:.qnix.grepw:{[pat;inp]
    pat:.util.ensureStr pat;
    inp where{[pat;line]any pat~/:" "vs?[floor[line]in .Q.a;line;" "]}[pat]each inp};

/ List directory contents
/ @return - dict
ls:.qnix.ls:{[args]
    / Ensure args is a list of strings
    if[10h~abs type args,:();args:enlist args];
    res:args!key each args:distinct`:.^.q.Hsym .util.strPath each args;
    .log.errorNotFound each where notFound:res~\:();
    (where not notFound)#res
    };

/ @param x - sym/string - filepath
/ @return - sym - filepath
touch:.qnix.touch:{hclose hopen x:.q.Hsym .util.strPath x;x}';

/ @param x - timespan
/ @example - .sleep.sleep 00:00:05
sleep:.qnix.sleep:{st:.z.p;while .z.p<st+x};
