// INFO: https://github.com/KxSystems/kdb/blob/master/utils/dbmaint.q
/ kdb+ partitioned database maintenance

// TODO: Standardise os utils with new lib
// TODO: Standardise function and argument names
.os.WIN:.z.o in`w32`w64;
.os.pth:{p:$[10h=type x;x;string x];if[.os.WIN;p[where"/"=p]:"\\"];(":"=first p)_ p};
.os.cpy:{system$[.os.WIN;"copy /v /z ";"cp "],.os.pth[x]," ",.os.pth y};
.os.del:{system$[.os.WIN;"del ";"rm "],.os.pth x};
.os.ren:{system$[.os.WIN;"move ";"mv "],.os.pth[x]," ",.os.pth y};
.os.here:{hsym`$system$[.os.WIN;"cd";"pwd"]};

/ General utils
invalidcolname:{(x in`i,.Q.res,key`.q)and x<>.Q.id x};
allcols:{[tabledir] get tabledir,`.d};
allpaths:{[dbdir;table]
    files:key dbdir;
    if[any files like"par.txt";:raze allpaths[;table]each hsym each`$read0` sv dbdir,`par.txt];
    files@:where files like"[0-9]*";
    ` sv'dbdir,'files,'table};
enum:{[dbdir;val] $[not 11=abs type val;val;(` sv dbdir,`sym)?val]};
coltype:{
    n:type x;
    c:.Q.ty$[n within 20 76;`$();
        n;x;
        not type raze x;();x];
    " "sv .Q.s1 each(n;c)};

/ Helper functions
add1col:{[tabledir;colname;defaultvalue]
    if[not colname in ac:allcols tabledir;
        num:count get` sv tabledir,first ac;
        colvalue:num#defaultvalue;
        .log.info"Adding column: ",(string colname)," (type ",(coltype colvalue),") to `",string tabledir;
        .[` sv tabledir,colname;();:;colvalue];
        @[tabledir;`.d;,;colname]]};

copy1col:{[tabledir;oldcol;newcol]
    if[(found:oldcol in ac)and not newcol in ac:allcols tabledir;
        .log.info"Copying column: ",(string oldcol)," to ",(string newcol)," in `",string tabledir;
        .os.cpy .` sv'tabledir,'(oldcol;newcol);
        @[tabledir;`.d;,;newcol]];
    if[not found;'.log.error"Column: ",(string oldcol)," is missing in `",string tabledir]};

delete1col:{[tabledir;col]
    if[col in ac:allcols tabledir;
        .log.info"Deleting column: ",(string col)," from `",string tabledir;
        .os.del[` sv tabledir,col];
        @[tabledir;`.d;:;ac except col]]};

find1col:{[tabledir;col]
    .log.info"Column: ",string[col],$[col in allcols tabledir;
        // NOTE: Use read1 if performance is an issue
        /" (type ",(.Q.s1"h"$first read1(` sv tabledir,col;2;1)),")";
        " (type ",(coltype get` sv tabledir,col),")";
        " *NOT*FOUND*"]," in ",.Q.s1 tabledir;};

fix1table:{[tabledir;goodpartition;goodpartitioncols]
    partitioncols:allcols tabledir;
    missingcols:goodpartitioncols except partitioncols;
    extracols:partitioncols except goodpartitioncols;
    if[not partitioncols~goodpartitioncols;
        .log.info"Fixing table `",string tabledir;
        {add1col[x;z;0#get y,z]}[tabledir;goodpartition]each missingcols;
        delete1col[tabledir]each extracols;
        reorder1cols[tabledir;goodpartitioncols]]};

fn1col:{[tabledir;col;fn]
    if[not col in allcols tabledir;'.log.error"Column: ",(string col)," is missing in `",string tabledir];
    oldattr:-2!oldvalue:get coldir:` sv tabledir,col;
    newattr:-2!newvalue:fn oldvalue;
    if[$[not oldattr~newattr;1b;not oldvalue~newvalue];
        .log.info"Resaving column: ",(string col)," (type ",(coltype newvalue),") in `",string tabledir;
        oldvalue:0; // NOTE: This prevents OS reports: Access is denied.
        .[coldir;();:;newvalue]]};

reorder1cols:{[tabledir;neworder]
    neworder:distinct neworder;
    missing:not all neworder in ac:allcols tabledir;
    mismatch:count[ac]<>count neworder;
    if[max error:missing,mismatch;
        '.log.error" AND "sv("Missing columns in new column order";"Mismatch in column counts")where error];
    .log.info"Reordering columns in `",string tabledir;
    @[tabledir;`.d;:;neworder]};

rename1col:{[tabledir;oldname;newname]
    if[not any found:oldname,newname in ac:allcols tabledir;
        '.log.error"Columns: ",(string oldname)," AND ",(string newname)," are missing in `",string tabledir];
    if[10b~found;
        .log.info"Renaming column: ",(string oldname)," to ",(string newname)," in `",string tabledir;
        .os.ren .` sv'tabledir,'(oldname;newname);
        @[tabledir;`.d;:;.[ac;where ac=oldname;:;newname]]]};

rename1table:{[oldname;newname]
    if[not any found:.util.exists each(oldname;newname);
        '.log.error"Tables: ",(string oldname)," AND ",(string newname)," are missing"];
    if[10b~found;
        .log.info"Renaming table: ",(string oldname)," to ",string newname;
        .os.ren[oldname;newname]]};

add1table:{[dbdir;tablename;table]
    .log.info"Adding table: ",string tablename;
    @[tablename;`;:;.Q.en[dbdir]0#table];};

/ Main functions
thisdb:`:.; / If functions are to be run within the database instance then use <thisdb> (`:.) as dbdir

/ @example - addcol[`:/data/taq;`trade;`noo;0h]
addcol:{[dbdir;table;colname;defaultvalue]
    if[invalidcolname colname;'.log.error"Invalid new column name: ",string colname];
    add1col[;colname;enum[dbdir;defaultvalue]]each allpaths[dbdir;table];};

/ @example - castcol[thisdb;`trade;`size;`short]
castcol:{[dbdir;table;col;newtype] fncol[dbdir;table;col;newtype$];};

/ @example - clearattr[thisdb;`trade;`sym]
clearattrcol:{[dbdir;table;col] setattrcol[dbdir;table;col;`];};

/ @example - copycol[`:/k4/data/taq;`trade;`size;`size2]
copycol:{[dbdir;table;oldcol;newcol]
    if[invalidcolname newcol;'.log.error"Invalid new column name: ",string newcol];
    copy1col[;oldcol;newcol]each allpaths[dbdir;table];};

/ @example - deletecol[`:/k4/data/taq;`trade;`iz]
deletecol:{[dbdir;table;col] delete1col[;col]each allpaths[dbdir;table];};

/ @example - findcol[`:/k4/data/taq;`trade;`iz]
findcol:{[dbdir;table;col] find1col[;col]each allpaths[dbdir;table];};

/ @example - fixtable[`:/k4/data/taq;`trade;`:/data/taq/2005.02.19]
fixtable:{[dbdir;table;goodpartition] fix1table[;goodpartition;allcols goodpartition]each allpaths[dbdir;table]except goodpartition;};

fncol:{[dbdir;table;col;fn] fn1col[;col;enum[dbdir]fn@]each allpaths[dbdir;table];};

/ @example - listcols[`:/k4/data/taq;`trade]
listcols:{[dbdir;table]
    .log.info"Table ",(string table)," columns: ";
    allcols first allpaths[dbdir;table]};

/ @example - renamecol[`:/k4/data/taq;`trade;`woz;`iz]
renamecol:{[dbdir;table;oldname;newname]
    if[invalidcolname newname;'.log.error"Invalid new column name: ",string newname];
    rename1col[;oldname;newname]each allpaths[dbdir;table];};

/ @example - reordercols[`:/k4/data/taq;`trade;reverse cols trade]
reordercols:{[dbdir;table;neworder] reorder1cols[;neworder]each allpaths[dbdir;table];};

/ @example - setattrcol[thisdb;`trade;`sym;`g] / `s `p `u
setattrcol:{[dbdir;table;col;newattr] fncol[dbdir;table;col;newattr#];};

/ @example - addtable[`:.;`trade;([]price...)]
addtable:{[dbdir;tablename;table] add1table[dbdir;;table]each allpaths[dbdir;tablename];};

/ @example - renametable[`:.;`trade;`transactions]
renametable:{[dbdir;old;new] rename1table'[allpaths[dbdir;old];allpaths[dbdir;new]];};

/
Examples:

addcol[`:.;`trade;`num;10];
addcol[`:.;`trade;`F;`test];
delete1col[`:./2000.10.02/trade;`F];
fixtable[`:.;`trade;`:./2000.10.03/trade];
reordercols[`:.;`quote;except[2 rotate cols quote;`date]];
clearattrcol[`:.;`trade;`sym];
setattrcol[`:.;`trade;`sym;`p];
castcol[`:.;`trade;`time;`second];
renamecol[`:.;`trade;`price;`PRICE];
pxcols:{(y,())renamecol[`:.;x]'z,()];
`PRICE`size renamecol[`:.;`trade]'`p`s;
