/########
/# Util #
/########

.util.isWin:{.z.o like"w*"};
.util.isWsl:{@[{system x;1b};"uname -a|grep -i wsl";0b]&.z.o like"l*"};

P:.util.print:0N!;
// INFO: https://code.kx.com/q/basics/handles/#connection-handles
O:.util.stdout:{-1 x;};
/E:.util.stderr:{-2 x;};

// NOTE:`not .util.isFile x` is not equivalent to `.util.isDir x`!
exists:.util.exists:{not()~key x};
isDir:.util.isDir:11h~type key@;
isFile:.util.isFile:{x~key x};

randSeed:.util.randSeed:{system"S ",0N?string[.z.t]except":."};
exceptNulls:.util.exceptNulls:{$[0>type x;'list;x where not null x]};

// INFO: https://code.kx.com/q/ref/hdel/#hdel
/ Recursive dir listing
.util.i.recurseDir:{[hidden;x]
    xIsDir:11h=type d:key x;
    if[hidden;d@:where not(d,:())like".*"];
    $[xIsDir;raze x,.z.s[hidden]each` sv/:x,/:d;d]};
dir:.util.recurseDirNoHidden:.util.i.recurseDir 0b;
// FIXME:
/
q)dir`
.q
.q.
.q.neg
q)diR`
'type
  [5]  /home/maurice/qoolbox/lib/util/util.q:25: .util.i.recurseDir:
    xIsDir:11h=type d:key x;
    if[hidden;d@:where not(d,:())like".*"];
                                 ^
    $[xIsDir;raze x,.z.s[hidden]each` sv/:x,/:d;d]}
\
diR:.util.recurseDir:.util.i.recurseDir 1b;
diR:.util.recurseDir:{$[11h=type d:key x;raze x,.z.s each` sv/:x,/:d;d]};
/ rm -rf
nuke:.util.recurseDel:hdel each desc .util.recurseDir@; / desc sort
/ Delete object from namespace
odel:.util.objectDel:{![$[1=count v;`.;` sv -1_v];();0b;(),last v:` vs x]};
/ Delete all objects from namespace. Namespaces cannot be deleted once it is created.
odels:.util.namespaceDel:{![x;();0b;`symbol$()]};

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
