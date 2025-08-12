/########
/# Core #
/########

.Q.hex:.Q.n,6#.Q.A;
/ Special characters on the keyboard
.Q.sc:"~`!@#$%^&*()_-+={[}]|\\:;\"'<,>.?/";
.q.xor:<>;
.q.rename:xcol;
.q.reorder:xcols;
.z.hf:.Q.host .z.a;
.z.ip:`$"."sv string 256h vs .z.a;
.util.isWin:{.z.o like"w*"};

P:.util.print:0N!;
// INFO: https://code.kx.com/q/basics/handles/#connection-handles
O:.util.stdout:{-1 x;};
/E:.util.stderr:{-2 x;};
.util.sysCd:{system"cd ",x};
.util.sysLoad:{system"l ",x};

// NOTE:`not .util.isFile x` is not equivalent to `.util.isDir x`!
exists:.util.exists:{not()~key x};
isDir:.util.isDir:11h~type key@;
isFile:.util.isFile:{x~key x};

randSeed:.util.randSeed:{system"S ",0N?string[.z.t]except":."};
exceptNulls:.util.exceptNulls:{$[0>type x;'list;x where not null x]};

// INFO: https://github.com/CillianReilly/qtools/blob/master/q.q
clear:.term.clear:{1"\033[H\033[J";};
c:.term.setSize:{system"c ",$[10h~type x;;" "sv string 2#]x};
full:.term.full:{.term.setSize 2000};
// TODO: Move to os?
resize:.term.resize:{.term.setSize first system"stty size"};
paste:.term.paste:{get{$[(""~r:read0 0)and not sum 124-7h$x inter"{}";x;x,` sv enlist r]}/[""]};

/ Ensure string
es:.util.ensureStr:{"",raze string x};
.util.removeColon:{(":"~first x)_x};
/ Normalize path
np:.util.normPath:ssr[;"//";"/"]over ssr[;"\\";"/"]@;
/ Normalize path windows
npw:.util.normPathWin:ssr[;"\\\\";"\\"]over ssr[;"/";"\\"]@;
/ String path
sp:.util.strPath:.util.removeColon .util.normPath .util.ensureStr@;
/ String path windows
spw:.util.strPathWin:.util.removeColon .util.normPathWin .util.ensureStr@;
// INFO: https://code.kx.com/q/ref/hdel/#hdel
/ Recursive dir listing
diR:.util.recurseDir:{$[11h=type d:key x;raze x,.z.s each` sv/:x,/:d;d]};
/ rm -rf
nuke:.util.recurseDel:hdel each desc .util.recurseDir@; / desc sort
/ Delete object from namespace
odel:.util.objectDel:{![$[1=count v;`.;` sv -1_v];();0b;(),last v:` vs x]};
/ Delete all objects from namespace. Namespaces cannot be deleted once it is created.
odels:.util.namespaceDel:{![x;();0b;`symbol$()]};

/ Human-readable bytes in specified unit
hbu:.util.humanReadableBytesInUnit:{[bytes;unit]
    units:`$b,"KMGTPEZY",'b:"B";
    if[specified:not(::)~unit;
        if[null units offset:units?unit:upper unit;'"Unit not found in: ",-3!units]];
    power:0^floor(binary:1024)xlog bytes,:();
    size:bytes%binary xexp power;
    if[specified;size*:binary xexp power-offset];
    $[specified;,\:[;string unit];,'[;string units power]]string[size],'" "};
hb:.util.humanReadableBytes:.util.humanReadableBytesInUnit[;(::)];

/ Fuzzy search namespace objects - case and order insensitive
/ @global `.fzf.cache - dict cache
/ @param pat - sym (list)
// NOTE: add a null sym to regenerate cache
/ @example - .util.fzfObject`search`pattern
/ @return - sym list
fzf:.util.fzfObject:{[pat]
    if[(any null pat)|not .util.exists`.fzf.cache;
        obj@:where -11h=type each obj:1_.util.recurseDir`;
        obj,:last each` vs'1_.util.recurseDir`.;
        .fzf.cache:obj!lower string .Q.id peach obj];
    pat:{"*",x,"*"}each lower string .util.exceptNulls(),pat;
    where{all y like/:x}[pat]peach .fzf.cache};
/ @return - table of objects and its values
fzfv:.util.fzfObjectVal:{[pat]([]obj;val:get each obj:.util.fzfObject pat)};
/ @return - table of objects and its approximate memory usage
fzfm:.util.fzfObjectMem:{[pat] delete val from update human:hb peach size from update size:{-22!x}peach val from .util.fzfObjectVal pat};
/ Get the object name of the value
/ @example - q)).util.getObjectName .z.s
/            q)whoami whoami
whoami:.util.getObjectName:{t:.util.fzfObjectVal`;exec obj from t where val~'x};

/draw:.util.draw:.[;;:;][;;]/[;];
draw:.util.draw:{[grid;coor;char] .[grid;coor;:;char]}[;;]/[;];
pad:.util.pad:{
    if[10h~type y;:x$y];
    padding:(0|abs[x]-count y)#(y,()) -1;
    x#$[x<0;padding,y;y,padding]};
/ Rotate grid (anti-)clockwise 90 degrees
acw90:.util.acw90:{reverse flip x};
cw90:.util.cw90:{reverse each flip x};

// INFO: https://code.kx.com/q/ref/sublist/#head-or-tail
.util.i.head:{[isHead;x]
    @[get;`.head.n;{.head.n:10}]; / Set default value here
    n:$[isHead;;neg].head.n;
    / If input is (::) or atomic number, return unary function: x sublist
    $[101h~typ:type x;n sublist;
        typ in neg 5 6 7h;($[isHead;;neg]x)sublist;
        n sublist x]};
head:.util.head:.util.i.head 1b;
tail:.util.tail:.util.i.head 0b;

// TODO: Add a smart-case feature
/ Grep util
/ @param pat - sym/string - pattern to search for
/ @param inp - string list - input text
grep:.util.grep:{[pat;inp]
    pat:raze string pat;
    if[not"*"in pat;pat:"*",pat,"*"];
    inp where inp like pat};
/ Exact word match
grepw:.util.grepw:{[pat;inp]
    pat:raze string pat;
    inp where{[pat;line]any pat~/:" "vs?[lower[line]in .Q.a;line;" "]}[pat]each inp};

/ List directory contents
ls:.util.ls:{
    {[path;lsDir]
        dirStr:.Q.s1 dir:$[path in(::;`);`:.;hsym`$.util.strPath path];
        if[not .util.exists dir;:-1(dirStr,": \"ERROR: No such file or directory\"";"")];
        if[lsDir;-1 dirStr,":"];
        -1(.Q.s1 key dir;"");
        }[;1<count x]each x;};
/ @return - dict
ls2:.util.lsReturnDict:{(!). flip
    {[path]
        dir:$[path in(::;`);`:.;hsym`$.util.strPath path];
        entries:$[.util.exists dir;`#key dir;`$"\"ERROR: No such file or directory\""];
        (dir;entries)
        }peach distinct(),x};

/###########
/# Logging #
/###########

/ Plain text
.log.plainText:{$["\n"in msg;"\n",;]msg:$[10h=abs type x;;-1_.Q.s@]x};
.log.lvl:`INFO;
.log.lvls:`DEBUG`INFO`WARN`ERROR`BACKTRACE`FATAL`SYSTEM;
.log.colors:`magenta`cyan`red`red`yellow`red`green;
.log.log:{[lvl;msg]
    / Return msg if below current logging level
    if[(>). ll:.log.lvls?.log.lvl,lvl:upper lvl;:msg];
    colors:@[get;".colors.enabled[]";0b];
    if[colors;1 .colors.ansi`bold,.log.colors[last ll],`default];
    1 string[.z.p]," ";
    1"[",string[lvl],"]: ";
    -1$[colors;,[;.colors.reset[]];].log.plainText msg;
    if[`FATAL~lvl;exit 1];
    if[`SYSTEM~lvl;:system msg];
    msg};
/ Sets the global logging functions
/ @global `.log.debug`.log.info`.log.warn`.log.error`.log.backtrace`.log.fatal`.log.system
{.Q.dd[`.log;lower x]set .log.log upper x}each .log.lvls;
sys:.log.system;

// INFO: https://code.kx.com/q/basics/debug/#trap
// INFO: https://code.kx.com/q/ref/dotq/#trpd-extend-trap
/ @example - .util.errTrapBacktrace[{x+y};(1;`2)]
ebt:.util.errTrapBacktrace:{[f;args] .Q.trpd[f;args,();{[err;msg] .log.error err; .log.backtrace .Q.sbt msg}]};

.util.banner:{[msg] (cover;side," ",msg," ",side;cover:(4+count msg)#side:"#")};
.log.banner:{[msg] .log.info each e,.util.banner[msg],e:enlist"";};

/##########
/# Colors #
/##########

/ Select Graphic Rendition
.colors.sgr:{[style;fg;bg]
    s:`reset`bold`faint`italic`underline!til 5;
    c:`default`black`red`green`yellow`blue`magenta`cyan`white!39 30 31 32 33 34 35 36 37;
    (s;c;c+10)@'style,fg,bg}.;
.colors.ansi:{[style;fg;bg]
    n:";"sv string .colors.sgr style,fg,bg;
    csi:"\033[";
    csi,n,"m"}.;
.colors.reset:{@[get;`.colors.i.reset;{:.colors.i.reset:.colors.ansi`reset``}]};
.colors.enabled:{@[get;`.colors.i.enabled;{:.util.isWin[]|"xterm-256color"~getenv`TERM}]};

/#############
/# Libraries #
/#############

/.log.lvl:`DEBUG;

.lib.initPath:{
    / Return if lib path has already been initialized
    if[@[get;`.lib.i.initPath;{:not .lib.i.initPath:1b}];:(::)];
    .log.debug"Initializing library path: .lib.path";
    if[""~.lib.path:getenv`QLIB;
        // INFO: https://code.kx.com/q/ref/value/#lambda
        // WARN: The structure of the result of value on a lambda is subject to change between versions
        f:.util.normPath(reverse get{})2;
        .lib.path:"/"sv(-1_"/"vs f),enlist"lib"];
    .log.debug".lib.path is: ",.lib.path;
    .log.debug"Finished initializing library path";
    };

/ (Re-)Scan for libraries
.lib.scan:{
    .lib.initPath[];
    .log.debug"Scanning for libraries: .lib.info";
    .lib.info:flip`name`path`file`loaded!"ss**"$\:();
    if[not()~name:key symPath:hsym`$.lib.path;
        path:.Q.dd[symPath]'[name];
        / Scan for files with .q extension, exclude files with .test.q extension and exclude files with spaces
        file:{f:key x;f where(f like"*.q")&(not f like"*.test.q")&not f like"* *"}each path;
        .lib.info:([]name;path;file);
        .lib.info:select from .lib.info where 0<count each file;
        .lib.info:update loaded:{count[x]#0b}each file from .lib.info;
        ];
    .log.debug"Libraries found: ",string count .lib.info;
    .log.debug"Finished scanning for libraries";
    };

/ @param x - sym - library name
.lib.i.require:{[force;libName]
    .lib.init[];
    .log.debug"Loading library: ",sx:string libName;
    if[not count lib:select from .lib.info where name=libName;.log.error"Library not found: ",sx;:(::)];
    lib:first lib;
    / Use .lib.requireForce to reload library
    if[not[force]&all lib`loaded;.log.debug"Library is already loaded: ",sx;:(::)];
    pwd:.util.sysCd"";
    / Tactical solution to handle filepath with spaces
    .util.sysCd .util.strPath lib`path;
    / Load library files with error trap to cd to pwd
    {[pwd;file]
        errTrapLoad:{[pwd;file;err]
            msg:"Failed to load file: ",(.util.normPath .util.sysCd[""],"/",file),". Error is: ",err;
            .util.sysCd pwd
            '.log.error msg;
            }[pwd;file];
        @[.util.sysLoad;file;errTrapLoad];
        }[pwd]each string lib`file;
    .lib.info:update loaded|1b from .lib.info where name=libName;
    .log.info"Finished loading library: ",sx;
    // INFO: cd handles filepath with spaces
    .util.sysCd pwd
    }each;
req:.lib.require:.lib.i.require 0b;
reqf:.lib.requireForce:.lib.i.require 1b;

.lib.init:{
    / Return if lib has already been initialized
    if[@[get;`.lib.i.init;{:not .lib.i.init:1b}];:(::)];
    .lib.scan[];
    .log.debug"Loading required libraries";
    .lib.require`parse`tree`docs;
    .lib.require`os`tplog;
    .lib.require`aoc`bits`cache`maths`uri`misc;
    /.lib.require`dbmaint;
    /.lib.require`partitioned;
    .log.debug"Finished loading required libraries";
    .log.info"QINIT SUCCEED";
    };

/ Error trap QINIT
@[.lib.init;[];{.log.error"QINIT FAILED"}];

// TODO: This is a temporary function. Create a test lib similar to k4unit.
//       Create a test for every function
.test.passed:{[e] $[e;exit;]0*-1"All tests passed!"};
