// INFO: https://github.com/KxSystems/kdb/blob/master/utils/dbmaint.q
/ kdb+ partitioned database maintenance

.lib.require`os;
.dbm.joinPath:{" "sv .os.strPath[.os.type]@'(x;y)};

/ General utils
invalidName:.dbm.invalidName:{(x in`i,.Q.res,key`.q)or x<>.Q.id x};
allCols:.dbm.allCols:{[tabDir] get tabDir,`.d};
allPaths:.dbm.allPaths:{[hdbDir;tabName]
    files:key hdbDir;
    if[any files like"par.txt";:raze .dbm.allPaths[;tabName]each hsym each`$read0` sv hdbDir,`par.txt];
    files@:where files like"[0-9]*";
    ` sv'hdbDir,'files,'tabName};
enum:.dbm.enum:{[hdbDir;val] $[not 11=abs type val;val;(` sv hdbDir,`sym)?val]};
colType:.dbm.colType:{
    n:type x;
    c:.Q.ty$[n within 20 76;`$();
        n;x;
        not type raze x;();x];
    " "sv .Q.s1 each(n;c)};
reload:.dbm.reload:{[hdbDir] .util.sysLoad .util.strPath hdbDir};

/ Helper functions
.dbm.add1Col:{[tabDir;colName;defaultVal]
    if[not colName in colNames:.dbm.allCols tabDir;
        num:count get` sv tabDir,first colNames;
        colVal:num#defaultVal;
        .log.info"Adding column: [",(string colName),"] of type: [",(.dbm.colType colVal),"] to: [",(.Q.s1 tabDir),"]";
        .[` sv tabDir,colName;();:;colVal];
        @[tabDir;`.d;,;colName]]};

.dbm.copy1Col:{[tabDir;oldName;newName]
    if[(found:oldName in colNames)and not newName in colNames:.dbm.allCols tabDir;
        .log.info"Copying column: [",(string oldName),"] to [",(string newName),"] in: [",(.Q.s1 tabDir),"]";
        .os.cp .dbm.joinPath .` sv'tabDir,'(oldName;newName);
        @[tabDir;`.d;,;newName]];
    if[not found;'.log.error"Column: [",(string oldName),"] is missing in: [",(.Q.s1 tabDir),"]"]};

.dbm.delete1Col:{[tabDir;colName]
    if[colName in colNames:.dbm.allCols tabDir;
        .log.info"Deleting column: [",(string colName),"] in: [",(.Q.s1 tabDir),"]";
        hdel[` sv tabDir,colName];
        @[tabDir;`.d;:;colNames except colName]]};

.dbm.find1Col:{[tabDir;colName]
    found:colName in .dbm.allCols tabDir;
    $[found;
        [lvl:`info;st:"Found";  msg:" of type [",(.dbm.colType get` sv tabDir,colName),"]"];
        [lvl:`warn;st:"Missing";msg:""]];
    .log.[lvl]st," column: [",(string colName),"]",msg," in [",(.Q.s1 tabDir),"]";};

.dbm.fix1Tab:{[tabDir;goodTabDir;goodColNames]
    missingColNames:goodColNames except colNames:.dbm.allCols tabDir;
    extraColNames:colNames except goodColNames;
    if[not colNames~goodColNames;
        .log.info"Fixing table: [",(.Q.s1 tabDir),"]";
        {.dbm.add1Col[x;z;0#get y,z]}[tabDir;goodTabDir]each missingColNames;
        .dbm.delete1Col[tabDir]each extraColNames;
        .dbm.reorder1Cols[tabDir;goodColNames]]};

.dbm.func1Col:{[tabDir;colName;func]
    if[not colName in .dbm.allCols tabDir;'.log.error"Column: [",(string colName),"] is missing in: [",(.Q.s1 tabDir),"]"];
    oldAttr:-2!oldVal:get colDir:` sv tabDir,colName;
    newAttr:-2!newVal:func oldVal;
    if[$[not oldAttr~newAttr;1b;not oldVal~newVal];
        .log.info"Resaving column: [",(string colName),"] of type: [",(.dbm.colType newVal),"] to: [",(.Q.s1 tabDir),"]";
        oldVal:0; // NOTE: This prevents OS reports: Access is denied.
        .[colDir;();:;newVal]]};

.dbm.reorder1Cols:{[tabDir;orderedColNames]
    orderedColNames:distinct orderedColNames;
    missingCols:not all orderedColNames in colNames:.dbm.allCols tabDir;
    mismatchCols:count[colNames]<>count orderedColNames;
    if[max error:missingCols,mismatchCols;
        '.log.error" AND "sv("Missing columns in new column order";"Mismatch in column counts")where error];
    .log.info"Reordering columns in [",(.Q.s1 tabDir),"]";
    @[tabDir;`.d;:;orderedColNames]};

.dbm.rename1Col:{[tabDir;oldName;newName]
    if[not any found:(oldName,newName)in colNames:.dbm.allCols tabDir;
        '.log.error"Columns: [",(string oldName),"] AND [",(string newName),"] are missing in: [",(.Q.s1 tabDir),"]"];
    if[10b~found;
        .log.info"Renaming column: [",(string oldName),"] to [",(string newName),"] in: [",(.Q.s1 tabDir),"]";
        .os.mv .dbm.joinPath .` sv'tabDir,'(oldName;newName);
        @[tabDir;`.d;:;.[colNames;where colNames=oldName;:;newName]]]};

.dbm.rename1Tab:{[oldName;newName]
    if[not any found:.util.exists each(oldName;newName);
        '.log.error"Tables: [",(string oldName),"] AND [",(string newName),"] are missing"];
    if[10b~found;
        .log.info"Renaming table: [",(string oldName),"] to [",(string newName),"]";
        .os.mv .dbm.joinPath[oldName;newName]]};

.dbm.add1Tab:{[hdbDir;tabDir;tabSchema]
    .log.info"Adding table: [",(.Q.s1 tabDir),"]";
    @[tabDir;`;:;.Q.en[hdbDir]0#tabSchema];};

/ Main functions
thisDb:.dbm.thisDb:`:.; / If functions are to be run within the database instance then use <thisDb> (`:.) as hdbDir

/ @example - addCol[`:/data/taq;`trade;`noo;0h]
addCol:.dbm.addCol:{[hdbDir;tabName;colName;defaultVal]
    if[.dbm.invalidName colName;'.log.error"Invalid new column name: [",(string colName),"]"];
    .dbm.add1Col[;colName;.dbm.enum[hdbDir;defaultVal]]each .dbm.allPaths[hdbDir;tabName];};

/ @example - castCol[thisDb;`trade;`size;`short]
castCol:.dbm.castCol:{[hdbDir;tabName;colName;newType]
    @[func:newType$;();{'.log.error"Invalid cast type: [",x,"]"}];
    .dbm.funcCol[hdbDir;tabName;colName;func];};

/ @example - clearAttrCol[thisDb;`trade;`sym]
clearAttrCol:.dbm.clearAttrCol:{[hdbDir;tabName;colName] .dbm.setAttrCol[hdbDir;tabName;colName;`];};

/ @example - copyCol[`:/k4/data/taq;`trade;`size;`size2]
copyCol:.dbm.copyCol:{[hdbDir;tabName;oldName;newName]
    if[.dbm.invalidName newName;'.log.error"Invalid new column name: [",(string newName),"]"];
    .dbm.copy1Col[;oldName;newName]each .dbm.allPaths[hdbDir;tabName];};

/ @example - deleteCol[`:/k4/data/taq;`trade;`iz]
deleteCol:.dbm.deleteCol:{[hdbDir;tabName;colName] .dbm.delete1Col[;colName]each .dbm.allPaths[hdbDir;tabName];};

/ @example - findCol[`:/k4/data/taq;`trade;`iz]
findCol:.dbm.findCol:{[hdbDir;tabName;colName] .dbm.find1Col[;colName]each .dbm.allPaths[hdbDir;tabName];};

/ @example - fixTab[`:/k4/data/taq;`trade;2005.02.19]
fixTab:.dbm.fixTab:{[hdbDir;tabName;goodPartition]
    goodTabDir:.Q.par[hdbDir;goodPartition;tabName];
    .dbm.fix1Tab[;goodTabDir;.dbm.allCols goodTabDir]each .dbm.allPaths[hdbDir;tabName]except goodTabDir;};

funcCol:.dbm.funcCol:{[hdbDir;tabName;colName;func] .dbm.func1Col[;colName;.dbm.enum[hdbDir]func@]each .dbm.allPaths[hdbDir;tabName];};

/ @example - listCols[`:/k4/data/taq;`trade]
listCols:.dbm.listCols:{[hdbDir;tabName]
    .log.info"Table [",(string tabName),"] columns: ";
    .dbm.allCols first .dbm.allPaths[hdbDir;tabName]};

/ @example - renameCol[`:/k4/data/taq;`trade;`woz;`iz]
renameCol:.dbm.renameCol:{[hdbDir;tabName;oldName;newName]
    if[.dbm.invalidName newName;'.log.error"Invalid new column name: [",(string newName),"]"];
    .dbm.rename1Col[;oldName;newName]each .dbm.allPaths[hdbDir;tabName];};

/ @example - reorderCols[`:/k4/data/taq;`trade;reverse cols trade]
reorderCols:.dbm.reorderCols:{[hdbDir;tabName;orderedColNames] .dbm.reorder1Cols[;orderedColNames]each .dbm.allPaths[hdbDir;tabName];};

/ @example - setAttrCol[thisDb;`trade;`sym;`g] / `s `p `u
setAttrCol:.dbm.setAttrCol:{[hdbDir;tabName;colName;newAttr] .dbm.funcCol[hdbDir;tabName;colName;newAttr#];};

/ @example - addTab[`:.;`trade;([]price...)]
addTab:.dbm.addTab:{[hdbDir;tabName;tabSchema]
    if[98h<>type tabSchema;'.log.error"Table schema should be type 98h"];
    .dbm.add1Tab[hdbDir;;0#tabSchema]each .dbm.allPaths[hdbDir;tabName];};

/ @example - renameTab[`:.;`trade;`transactions]
renameTab:.dbm.renameTab:{[hdbDir;old;new] .dbm.rename1Tab'[.dbm.allPaths[hdbDir;old];.dbm.allPaths[hdbDir;new]];};

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
