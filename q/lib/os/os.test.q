// TEST: helper functions
cmdFail:{'(" or "sv{"`",x,"`"}each string(),x)," function failed!"};
quoteSymPathWithSpacesAndJoin:{" "sv{$[" "in x;"\"",x,"\"";x]}each string x};
notAllExists:{not all .util.exists each x};
anyExists:{any .util.exists each x};

// TEST: os info
if[.os.name~`unknown;'"unknown os name"];
if[not .os.type in`l`m`s`v`w;'"unknown os type"];
if[not .os.arch in`x86`x86_64;'"unknown os arch"];
.os.run[;`]each`ver`nproc`termsize;

// TEST: Create tmp dir
.util.print pwd:.os.run[`pwd;`];
.os.run[cmd:`rmrf;testDir:`:tmp];
if[.util.exists testDir;cmdFail cmd];
.os.run[cmd:`cd;testDir];
if[not testDir~hsym last` vs hsym`$.util.normPath .util.print .os.run[`pwd;""];cmdFail cmd,`pwd];

// TEST: mkdir, rmdir
{[newDirs]
    newDirsh:hsym newDirs;
    newDirss:quoteSymPathWithSpacesAndJoin newDirs;
    .os.run[cmd:`mkdir;newDirss];
    .util.stdout .os.run[`ls;`];
    if[notAllExists newDirsh;cmdFail cmd];
    .os.run[cmd:`rmdir;newDirss];
    .util.stdout .os.run[`ls;`];
    if[anyExists newDirsh;cmdFail cmd];
    }each(`Creating`multiple`directories,`$"path with spaces";newDirs:`$("Creating/nested/directories";"Nested path/with spaces"));

// TEST: rmrf
/ Remove recursive from top level directories
newDirsh:hsym newDirs:`${first"/"vs .util.strPath x}each newDirs;
newDirss:quoteSymPathWithSpacesAndJoin newDirs;
.os.run[cmd:`rmrf;newDirss];
.util.stdout .os.run[`ls;`];
if[anyExists newDirsh;cmdFail cmd];

// TEST: touch, cp, mv, rm, ln
newFilesh:hsym newFiles:`emptyFile,`$"duplicated empty file";
.os.run[cmd:`touch;first newFiles];
.os.run[`cp;quoteSymPathWithSpacesAndJoin newFiles];
.util.stdout .os.run[`ls;`];
if[notAllExists newFilesh;cmdFail cmd,`cp];
.os.run[cmd:`mv;quoteSymPathWithSpacesAndJoin@[newFiles;1;:;newFile:`renamedEmptyFile]];
.util.stdout .os.run[`ls;`];
if[notAllExists newFilesh:@[newFilesh;0;:;hsym newFile];cmdFail cmd];
.os.run[cmd:`rm;quoteSymPathWithSpacesAndJoin@[newFiles;0;:;newFile:`renamedEmptyFile]];
.util.stdout .os.run[`ls;`];
if[anyExists newFilesh;cmdFail cmd];
.os.run[cmd:`touch;first newFiles];
if[`w~.os.type;newFiles:reverse newFiles];
.os.run[`ln;path:quoteSymPathWithSpacesAndJoin newFiles];
.util.stdout .os.run[`ls;`];
if[notAllExists newFilesh:hsym newFiles;cmdFail cmd,`ln];
.os.run[cmd:`rm;path];
.util.stdout .os.run[`ls;`];
if[anyExists newFilesh;cmdFail cmd];

// TEST: cpr
newDirs:`backup1;
.os.run[`mkdir;" "sv pathv:string[newDirs],/:"/dir",/:numBackup:"12"];
{.os.run[`touch;ssr[x;"dir";"file"]]}each pathv;
newDirsh:hsym newDirs:newDirs,`$ssr[string newDirs]. numBackup;
.os.run[cmd:`cpr;path:quoteSymPathWithSpacesAndJoin newDirs];
.util.stdout .os.run[`ls;path];
if[not(~).{{1_"/"vs .util.strPath x}each .util.recurseDir x}each newDirsh;cmdFail cmd];
.os.run[cmd:`rmrf;path];
.util.stdout .os.run[`ls;`];

// TEST: Cleanup tmp dir
.os.run[cmd:`cd;pwd];
if[not pwd~.util.print .os.run[`pwd;""];cmdFail cmd,`pwd];
.util.stdout .os.run[`ls;`];
.os.run[cmd:`rmrf;testDir];
.util.stdout .os.run[`ls;`];
if[.util.exists testDir;cmdFail cmd];

// TEST: sleep
st:.z.t;
.os.run[cmd:`sleep;s:1];
et:.z.t
if[s>int:`second$et-st;cmdFail cmd];

.test.passed 0b;
