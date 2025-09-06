.lib.st:.z.p;
/ -clean flag
if[`clean in key .Q.opt .z.x;:(::)];

/########
/# Core #
/########

.q.Hsym:{hsym$[11h~abs type x;;`$]x};

.util.sysCd:{system"cd ",x};
.util.sysLoad:{system"l ",x};
// INFO: https://code.kx.com/q/ref/value/#lambda
// WARN: The structure of the result of value on a lambda is subject to change between versions
/ @param x - lambda - {} from script
.util.getScriptPath:{.util.normPath(reverse get x)2};
.util.isStartupFile:{(~).{last` vs .q.Hsym x}each(.z.f;.util.getScriptPath x)};

/ Ensure string
es:.util.ensureStr:{"",raze string x};
.util.removeColon:{(":"~first x)_x};
.util.i.strPath:.util.removeColon .util.ensureStr@;
.util.isStr:10h~abs type@;
/ @param filePath - sym/string
/ @return directory path of the same input type
.util.i.normPath:{[normalize;filePath]
    filePathStr:.util.i.strPath filePath;
    filePathStr:normalize filePathStr;
    $[.util.isStr filePath;;.q.Hsym]filePathStr};
/ Normalize path
np:.util.normPath:.util.i.normPath[ssr[;"//";"/"]over ssr[;"\\";"/"]@];
/ Normalize path windows
npw:.util.normPathWin:.util.i.normPath[ssr[;"\\\\";"\\"]over ssr[;"/";"\\"]@];
/ String path
sp:.util.strPath:.util.i.strPath .util.normPath@;
/ String path windows
spw:.util.strPathWin:.util.i.strPath .util.normPathWin@;
/ @param filePath - sym/string
/ @return directory path of the same input type
.util.dirname:{[filePath]
    filePathStr:.util.i.strPath filePath;
    found:(pathSep:"/\\")in filePathStr;
    pathSep:$[all found;[filePathStr:.util.normPath filePathStr;"/"];
        any found;first pathSep where found;"/"];
    dirname:pathSep sv -1_pathSep vs filePathStr;
    $[.util.isStr filePath;;.q.Hsym]dirname};

/###########
/# Logging #
/###########

/ Plain text
.log.plainText:{$["\n"in msg;"\n",;]msg:$[.util.isStr x;;-1_.Q.s@]x};
.log.reset:{.log.lvl:`INFO};
.log.reset[];
.log.pause:{
    if[@[value;`.log.paused;{:not .log.paused:1b}];:(::)];
    .log.paused:1b;
    .log.i.lvl:.log.lvl;
    .log.lvl:`ERROR};
.log.resume:{
    if[not@[value;`.log.paused;{:.log.paused:0b}];:(::)];
    .log.paused:0b;
    .log.lvl:.log.i.lvl};
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

.error.fileNotFound:"ERROR: No such file or directory";

/#############
/# Libraries #
/#############

/.log.lvl:`DEBUG;
.log.pause[];

.lib.initPath:{
    / Return if lib path has already been initialized
    if[@[get;`.lib.i.initPath;{:not .lib.i.initPath:1b}];:(::)];
    .log.debug"Initializing library path: .lib.path";
    if[""~.lib.path:getenv`QLIB;
        scriptPath:.util.getScriptPath{};
        .lib.path:.util.dirname[scriptPath],"/lib"];
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
    if[not count lib:select from .lib.info where name=libName;
        .log.error"Library not found: ",sx;
        :if[not null libName;
            if[count similar:exec name from .lib.info where name like("*",string[libName],"*");
                .log.info"Did you mean: ",.Q.s1 similar]]];
    lib:first lib;
    / Use .lib.requireForce to reload library
    if[not[force]&all lib`loaded;:{}.log.debug"Library is already loaded: ",sx];
    pwd:.util.sysCd"";
    / Tactical solution to handle filepath with spaces
    .util.sysCd .util.strPath lib`path;
    / Load library files with error trap to cd to pwd
    {[pwd;file]
        errTrapLoad:{[pwd;file;err]
            msg:"Failed to load file: ",(.util.normPath .util.sysCd[""],"/",file),". Error is: ",err;
            .util.sysCd pwd;
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
    .lib.require`dotx`util;
    .log.debug"Finished loading required libraries";
    .log.debug"Loading optional libraries";
    .lib.require`colors`term`parse`docs`tree`fzf`bytes`browse`qnix;
    .lib.require`os`tplog;
    .lib.require`aoc`bits`cache`maths`uri`misc;
    .log.debug"Finished loading optional libraries";
    .log.resume[];
    .log.info"QINIT SUCCEED. Startup time: ",string(.lib.et:.z.p)-.lib.st;;
    };

/ Error trap QINIT
@[.lib.init;[];{.log.error"QINIT FAILED"}];
