/########
/# Util #
/########

.util.isWin:{.z.o like"w*"};
.util.isWsl:{@[{system x;1b};"uname -a|grep -i wsl";0b]&.z.o like"l*"};

P:.util.print:0N!;
shuffle:.util.shuffle:0N?;
// INFO: https://code.kx.com/q/basics/handles/#connection-handles
O:.util.stdout:{-1 x;};
/E:.util.stderr:{-2 x;};

/ Reload q script
reload:.util.reload:{.util.sysLoad string .z.f};

// NOTE:`not .util.isFile x` is not equivalent to `.util.isDir x`!
exists:.util.exists:{not()~key x};
isDir:.util.isDir:11h~type key@;
isFile:.util.isFile:{x~key x};

stab:.util.showTab:{([]x)};
.util.addQuotes:{q,x,q:"\""};
.util.removeQuotes:{x except"\""};
match:.util.match:{1=count distinct x};
randSeed:.util.randSeed:{system"S ",0N?string[.z.t]except":."};
exceptNulls:.util.exceptNulls:{$[0>type x;'list;x where not null x]};

// INFO: https://code.kx.com/q/ref/hdel/#hdel
/ Recursive dir listing
.util.i.recurseDir:{[hidden;x] $[11h=type d:key x;raze x,.z.s[hidden]each` sv/:x,/:d$[hidden;;where not d like".*"];d]};
dir:.util.recurseDirNoHidden:.util.i.recurseDir 0b;
diR:.util.recurseDir:.util.i.recurseDir 1b;

/ rm -rf
nuke:.util.recurseDel:hdel each desc .util.recurseDir@; / desc sort
/ Delete object from namespace
odel:.util.objectDel:{![$[1=count v;`.;` sv -1_v];();0b;(),last v:` vs x]};
/ Delete all objects from namespace. Namespaces cannot be deleted once it is created.
odels:.util.namespaceDel:{![x;();0b;`symbol$()]};

/ Bytes to human-readable bytes in specified unit
/ NOTE: Max unit is YB (Yobibytes)
/ @param x - number (list) - bytes
/ @param unit - sym
/ @return - string list
/ @example - .util.humanBytesUnit[1023;`kb]
/            .util.humanBytesUnit[(1024;2.5*1024 xexp 3;3.75*1024 xexp 4);`MB]
hbu:.util.humanBytesUnit:{[bytes;unit]
    units:`$b,"KMGTPEZY",'b:"B";
    if[specified:not(::)~unit;
        if[null units offset:units?unit:upper unit;:{}.log.error"Unit not found in: ",.Q.s1 units]];
    power:(-1+count units)&0^floor(binary:1024)xlog bytes,:();
    size:bytes%binary xexp power;
    if[specified;size*:binary xexp power-offset];
    $[specified;,\:[;string unit];,'[;string units power]]string[size],'" "};
/ Human-readable bytes in closest unit
/ @example - .util.humanBytes 1023 1024
hb:.util.humanBytes:.util.humanBytesUnit[;(::)];

/ Human-readable bytes in specified unit to bytes
/ @param big - boolean - 1b if big number
/ @param humanBytes - string list
.util.i.bytesHuman:{[big;humanBytes]
    if[any 2<count each parts:(except[;enlist""]vs[" "]@)each string(),`$humanBytes;:{}.log.error"Invalid format"];
    units:`$b,"KMGTPEZY",'b:"B";
    if[any 8<power:units?`B^`$parts[;1];:{}.log.error"Unit not found in: ",.Q.s1 units];
    num:parts[;0];
    $[big;
        [.lib.require`maths;
            if[any null"F"$num;:{}.log.error"Invalid number"];
            {.maths.bigPrdFast enlist[x],string y#1024}'[num;power]];
        [system"P 0";
            ("F"$num)*1024 xexp power]]};
/ @return - float list
/ @example - .util.bytesHuman("1 KB";"2.5 GB";"3.75 TB")
bh:.util.bytesHuman:.util.i.bytesHuman 0b;
/ @return - string list - big numbers (bytes) that cannot be represented in kdb
/ @example - .util.bigBytesHuman"1048576 YB"
bbh:.util.bigBytesHuman:.util.i.bytesHuman 1b;

// INFO: https://code.kx.com/q/ref/value/#lambda
/ Valence (rank) of a function
valence:.util.valence:{if[100h<>type x;'function]; count value[x]1};

/draw:.util.draw:.[;;:;][;;]/[;];
draw:.util.draw:{[grid;coor;char] .[grid;coor;:;char]}[;;]/[;];
pad:.util.pad:{
    if[.util.isStr y;:x$y];
    padding:(0|abs[x]-count y)#(y,()) -1;
    x#$[x<0;padding,y;y,padding]};
/ Rotate grid (anti-)clockwise 90 degrees
acw90:.util.acw90:{reverse flip x};
cw90:.util.cw90:{reverse each flip x};

/ Convert kdb to Unix timestamp in seconds
/ kdb+ Epoch: Starts on 2000.01.01 and measures time in nanoseconds
/ Unix Epoch: Starts on 1970.01.01 and traditionally measures time in seconds
/ @param x - timestamp/datetime
.util.unixTimeStamp:{
    floor$[-12h~typ:type x;((-).`long$x,1970.01.01D)%1e9;
        -15h~typ;86400*x-1970.01.01T;'.log.error"Unsupported input type"]};
