// INFO: https://github.com/KxSystems/kdb/blob/master/utils/dbmaint.q
/ kdb+ partitioned database maintenance

.lib.require`os;
joinPath:{" "sv .os.strPath[.os.type]@'(x;y)};

/ General utils
invalidName:{(x in`i,.Q.res,key`.q)and x<>.Q.id x};
allCols:{[tabDir] get tabDir,`.d};
allPaths:{[hdbDir;tabName]
    files:key hdbDir;
    if[any files like"par.txt";:raze allPaths[;tabName]each hsym each`$read0` sv hdbDir,`par.txt];
    files@:where files like"[0-9]*";
    ` sv'hdbDir,'files,'tabName};
enum:{[hdbDir;val] $[not 11=abs type val;val;(` sv hdbDir,`sym)?val]};
colType:{
    n:type x;
    c:.Q.ty$[n within 20 76;`$();
        n;x;
        not type raze x;();x];
    " "sv .Q.s1 each(n;c)};
reload:{[hdbDir] system"l ",.util.strPath hdbDir};

/ Helper functions
add1Col:{[tabDir;colName;defaultVal]
    if[not colName in colNames:allCols tabDir;
        num:count get` sv tabDir,first colNames;
        colVal:num#defaultVal;
        .log.info"Adding column: ",(string colName)," (type ",(colType colVal),") to ",-3!tabDir;
        .[` sv tabDir,colName;();:;colVal];
        @[tabDir;`.d;,;colName]]};

copy1Col:{[tabDir;oldName;newName]
    if[(found:oldName in colNames)and not newName in colNames:allCols tabDir;
        .log.info"Copying column: ",(string oldName)," to ",(string newName)," in ",-3!tabDir;
        .os.cp joinPath .` sv'tabDir,'(oldName;newName);
        @[tabDir;`.d;,;newName]];
    if[not found;'.log.error"Column: ",(string oldName)," is missing in ",-3!tabDir]};

delete1Col:{[tabDir;colName]
    if[colName in colNames:allCols tabDir;
        .log.info"Deleting column: ",(string colName)," from ",-3!tabDir;
        hdel[` sv tabDir,colName];
        @[tabDir;`.d;:;colNames except colName]]};

find1Col:{[tabDir;colName]
    .log.info"Column: ",string[colName],$[colName in allCols tabDir;
        // NOTE: Use read1 if performance is an issue
        /" (type ",(.Q.s1"h"$first read1(` sv tabDir,colName;2;1)),")";
        " (type ",(colType get` sv tabDir,colName),")";
        // TODO: Maybe change this to warn?
        " *NOT*FOUND*"]," in ",.Q.s1 tabDir;};

fix1Tab:{[tabDir;goodTabDir;goodColNames]
    missingColNames:goodColNames except colNames:allCols tabDir;
    extraColNames:colNames except goodColNames;
    if[not colNames~goodColNames;
        .log.info"Fixing table ",-3!tabDir;
        {add1Col[x;z;0#get y,z]}[tabDir;goodTabDir]each missingColNames;
        delete1Col[tabDir]each extraColNames;
        reorder1Cols[tabDir;goodColNames]]};

func1Col:{[tabDir;colName;func]
    if[not colName in allCols tabDir;'.log.error"Column: ",(string colName)," is missing in ",-3!tabDir];
    oldAttr:-2!oldVal:get colDir:` sv tabDir,colName;
    newAttr:-2!newVal:func oldVal;
    if[$[not oldAttr~newAttr;1b;not oldVal~newVal];
        .log.info"Resaving column: ",(string colName)," (type ",(colType newVal),") in ",-3!tabDir;
        oldVal:0; // NOTE: This prevents OS reports: Access is denied.
        .[colDir;();:;newVal]]};

reorder1Cols:{[tabDir;orderedColNames]
    orderedColNames:distinct orderedColNames;
    missingCols:not all orderedColNames in colNames:allCols tabDir;
    mismatchCols:count[colNames]<>count orderedColNames;
    if[max error:missingCols,mismatchCols;
        '.log.error" AND "sv("Missing columns in new column order";"Mismatch in column counts")where error];
    .log.info"Reordering columns in ",-3!tabDir;
    @[tabDir;`.d;:;orderedColNames]};

rename1Col:{[tabDir;oldName;newName]
    if[not any found:(oldName,newName)in colNames:allCols tabDir;
        '.log.error"Columns: ",(string oldName)," AND ",(string newName)," are missing in ",-3!tabDir];
    if[10b~found;
        .log.info"Renaming column: ",(string oldName)," to ",(string newName)," in ",-3!tabDir;
        .os.mv joinPath .` sv'tabDir,'(oldName;newName);
        @[tabDir;`.d;:;.[colNames;where colNames=oldName;:;newName]]]};

rename1Tab:{[oldName;newName]
    if[not any found:.util.exists each(oldName;newName);
        '.log.error"Tables: ",(string oldName)," AND ",(string newName)," are missing"];
    if[10b~found;
        .log.info"Renaming table: ",(string oldName)," to ",string newName;
        .os.mv joinPath[oldName;newName]]};

add1Tab:{[hdbDir;tabDir;tabSchema]
    .log.info"Adding table: ",string tabDir;
    @[tabDir;`;:;.Q.en[hdbDir]0#tabSchema];};

/ Main functions
thisDb:`:.; / If functions are to be run within the database instance then use <thisDb> (`:.) as hdbDir

/ @example - addCol[`:/data/taq;`trade;`noo;0h]
addCol:{[hdbDir;tabName;colName;defaultVal]
    if[invalidName colName;'.log.error"Invalid new column name: ",string colName];
    add1Col[;colName;enum[hdbDir;defaultVal]]each allPaths[hdbDir;tabName];};

/ @example - castCol[thisDb;`trade;`size;`short]
castCol:{[hdbDir;tabName;colName;newType] funcCol[hdbDir;tabName;colName;newType$];};

/ @example - clearAttrCol[thisDb;`trade;`sym]
clearAttrCol:{[hdbDir;tabName;colName] setAttrCol[hdbDir;tabName;colName;`];};

/ @example - copyCol[`:/k4/data/taq;`trade;`size;`size2]
copyCol:{[hdbDir;tabName;oldName;newName]
    if[invalidName newName;'.log.error"Invalid new column name: ",string newName];
    copy1Col[;oldName;newName]each allPaths[hdbDir;tabName];};

/ @example - deleteCol[`:/k4/data/taq;`trade;`iz]
deleteCol:{[hdbDir;tabName;colName] delete1Col[;colName]each allPaths[hdbDir;tabName];};

/ @example - findCol[`:/k4/data/taq;`trade;`iz]
findCol:{[hdbDir;tabName;colName] find1Col[;colName]each allPaths[hdbDir;tabName];};

/ @example - fixTab[`:/k4/data/taq;`trade;2005.02.19]
fixTab:{[hdbDir;tabName;goodPartition]
    goodTabDir:.Q.par[hdbDir;goodPartition;tabName];
    fix1Tab[;goodTabDir;allCols goodTabDir]each allPaths[hdbDir;tabName]except goodTabDir;};

funcCol:{[hdbDir;tabName;colName;func] func1Col[;colName;enum[hdbDir]func@]each allPaths[hdbDir;tabName];};

/ @example - listCols[`:/k4/data/taq;`trade]
listCols:{[hdbDir;tabName]
    .log.info"Table ",(string tabName)," columns: ";
    allCols first allPaths[hdbDir;tabName]};

/ @example - renameCol[`:/k4/data/taq;`trade;`woz;`iz]
renameCol:{[hdbDir;tabName;oldName;newName]
    if[invalidName newName;'.log.error"Invalid new column name: ",string newName];
    rename1Col[;oldName;newName]each allPaths[hdbDir;tabName];};

/ @example - reorderCols[`:/k4/data/taq;`trade;reverse cols trade]
reorderCols:{[hdbDir;tabName;orderedColNames] reorder1Cols[;orderedColNames]each allPaths[hdbDir;tabName];};

/ @example - setAttrCol[thisDb;`trade;`sym;`g] / `s `p `u
setAttrCol:{[hdbDir;tabName;colName;newAttr] funcCol[hdbDir;tabName;colName;newAttr#];};

/ @example - addTab[`:.;`trade;([]price...)]
addTab:{[hdbDir;tabName;tabSchema]
    if[98h<>type tabSchema;'.log.error"Table schema should be type 98h"];
    add1Tab[hdbDir;;0#tabSchema]each allPaths[hdbDir;tabName];};

/ @example - renameTab[`:.;`trade;`transactions]
renameTab:{[hdbDir;old;new] rename1Tab'[allPaths[hdbDir;old];allPaths[hdbDir;new]];};

/
Examples:

addCol[`:.;`trade;`num;10];
addCol[`:.;`trade;`F;`test];
delete1Col[`:./2000.10.02/trade;`F];
fixTab[`:.;`trade;`:./2000.10.03/trade];
reorderCols[`:.;`quote;except[2 rotate cols quote;`date]];
clearAttrCol[`:.;`trade;`sym];
setAttrCol[`:.;`trade;`sym;`p];
castCol[`:.;`trade;`time;`second];
renameCol[`:.;`trade;`price;`PRICE];
pxcols:{(y,())renameCol[`:.;x]'z,()];
`PRICE`size renameCol[`:.;`trade]'`p`s;
