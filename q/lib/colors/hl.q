/#############
/# Highlight #
/#############

/ Custom tokenizer
.hl.token:{(where b|(not b)&1b,-1_b:x in"\"",.Q.br)_x};
/ Token with trap
.hl.tokenTrap:@[-4!;;];
/ Secondary token trap
.hl.tokenSecTrap:{y;raze{.hl.tokenTrap[x;enlist x]}each .hl.token x};

/ Merge hex code in tokens
.hl.mergeHex:{[tokens]
    if[.hl.hexEnabled[];
        if[count i:where b:tokens~\:(),"#";
            hex:raze each@[tokens;j:0 1+/:i];
            isHex:where .colors.i.isHex each hex;
            tokens:@[tokens;j[isHex;0];:;hex isHex]where@[1b|b;j[isHex;1];:;0b];
            ];
        ];
    tokens};

.hl.hlLine:{
    / Fast mode disables secondary token trap
    trap:$[.hl.fastEnabled[];enlist x;.hl.tokenSecTrap x];
    tokens:.hl.tokenTrap[x;trap];
    tokens:.hl.mergeHex tokens;
    raze .hl.hl each tokens};

.hl.pi:{
    if[(::)~r:get x;:(::)];
    lines:"\n"vs -1_.Q.s r;
    -1 .hl.hlLine each lines;
    };

.hl.colors:(!). flip(
    (`purple;"#ca72e4") ;
    (`green ;"#97ca72") ;
    (`orange;"#d99a5e") ;
    (`blue  ;"#5ab0f6") ;
    (`yellow;"#ebc275") ;
    (`cyan  ;"#4dbdcb") ;
    (`red   ;"#ef5f6b") ;
    (`grey  ;"#546178"));

.hl.todoColors:(
    (`TEST`DEBUG`TESTING                    ;`purple) ;
    (`PERF`OPTIM`PERFORMANCE`OPTIMIZE`PASSED;`green ) ;
    (`WARN`WARNING                          ;`orange) ;
    (`TODO                                  ;`blue  ) ;
    (`HACK                                  ;`yellow) ;
    (`NOTE`INFO`HINT                        ;`cyan  ) ;
    (`FIX`ERROR`FIXME`BUG`FIXIT`ISSUE`FAILED;`red   ));

.hl.i.todoPatterns:{"/  ",'{x,"[",upper[y],lower[y],"]"}/["";x],/:"  :"};
.hl.todoPatterns:{(raze .hl.i.todoPatterns each string(),x 0;x 1)}each .hl.todoColors;

.hl.i.hlInner:{[x;outerCol;innerCol;innerInv;hlHex]
    ansi:{
        / Compute opposite color for hex code
        bg:$[z;.colors.oppositeHex x;()];
        .colors.ansi[`reset,``inverse y;x;bg]};
    ansi[innerCol;innerInv;hlHex],x,ansi[outerCol;0b;0b]};

.hl.i.hl:{[x;outerCol]
    if[.hl.hexEnabled[];
        x:ssr[x;.colors.i.hex;{.hl.i.hlInner[x;y;x;1b;1b]}[;.hl.colors outerCol]]];
    .colors.wrap[`reset;.hl.colors outerCol;();x]};

.hl.i.hlComment:{[x;outerCol]
    if[.hl.todoEnabled[];
        x:{ssr/[x;z 0;.hl.i.hlInner[;.hl.colors y;.hl.colors z 1;1b;0b]]}[;outerCol]/[x;.hl.todoPatterns]];
    .hl.i.hl[x;outerCol]};

.hl.i.hlStr:{[x;outerCol;innerCol]
    / Escape sequences
    x:ssr/[x;("\\[0-9][0-9][0-9]";"\\[^0-9]");.hl.i.hlInner[;.hl.colors outerCol;.hl.colors innerCol;0b;0b]];
    .hl.i.hl[x;outerCol]};

.hl.hl:{
    hl:.hl.i.hl x,:();
    / Comment
    if[(any x like/:("/*";" /*"))&not any x in("/:";(),"/");:.hl.i.hlComment[x;`grey]];
    / Conditional
    if[x in("do";"while";"if");:hl`purple];
    / Data manipulation language
    if[x in("select";"update";"delete";"exec";"from";"by";"fby";"where";"aj";"aj0";"ajf";"ajf0";"ej";"ij";"ijf";"lj";"ljf";"uj";"ujf";"wj";"wj1";"upsert";"insert");
        :hl`purple];
    / Keyword
    if[(`$x)in .Q.res,key[`.q]except`;:hl`purple];
    / Internal function
    if[any x like/:".[hjmQqz]",/:("";".*");:hl`yellow];
    / System command
    if[x like"\\?*";:hl`cyan];
    / Null
    if[any x like/:"0[Nn]",/:("";"[ghijefpmdznuvt]");:hl`cyan];
    / Infinity
    if[any x like/:"0[Ww]",/:("";"[hijepmdznuvt]");:hl`cyan];
    / Bracket
    / if[(1~count x)&x[0]in .hl.br;:hl`red];
    typ:type tree:@[parse;x;()];
    ty:.Q.ty tree;
    / Number
    if[abs[typ]within 1 9;:hl`orange];
    / String
    if[10h~abs typ;:.hl.i.hlStr[x;`green;`cyan]];
    / Namespace
    if[(-11h~typ)&x like".*";:hl`blue];
    / Symbol
    if[("S"~upper ty)&x like"`*";;:hl`cyan];
    / Temporal
    if[abs[typ]within 12 19;:hl`cyan];
    / Operator
    if[typ within 101 111;:hl`yellow];
    hl()};

.hl.on:{
    if[.util.exists`.z.pi;.z.oldPi:.z.pi];
    .z.pi:.hl.pi;
    };
.hl.off:{system"x .z.pi"};

.hl.fastEnabled:{@[get;`.hl.i.fastEnabled;0b]};
.hl.fastOn:{.hl.i.fastEnabled:1b};
.hl.fastOff:{.hl.i.fastEnabled:0b};

.hl.hexEnabled:{@[get;`.hl.i.hexEnabled;0b]};
.hl.hexOn:{.hl.i.hexEnabled:1b};
.hl.hexOff:{.hl.i.hexEnabled:0b};

.hl.todoEnabled:{@[get;`.hl.i.todoEnabled;0b]};
.hl.todoOn:{.hl.i.todoEnabled:1b};
.hl.todoOff:{.hl.i.todoEnabled:0b};

.hl.on[];
.hl.fastOff[];
.hl.hexOn[];
.hl.todoOn[];
