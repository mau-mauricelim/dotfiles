\c 2000 2000
gen:til n:100;
// INFO: https://code.kx.com/q/basics/datatypes/
saveTab:{[dt]
    tab::([]
        timespanColumn:n?.z.n;
        symbolColumn:n?`AAPL`IBM`GE`GOOG;
        listColumn:n?(-10.0;3.1415e;1b;`abc;"z");
        booleanColumn:n?0b;
        guidColumn:n?0Ng;
        byteColumn:n?0x0;
        byteNestedColumn:-18!'gen;
        shortColumn:n?0Wh;
        longNestedColumn:{2?0W}each gen;
        floatColumn:n?10.0;
        floatNestedColumn:{3?100.0}each gen;
        charColumn:n?" ");
    `symbolColumn`timespanColumn xasc`tab;
    .log.info"Saving tab table to partition: ",string dt;
    .Q.dpft[dst;dt;`symbolColumn;`tab]; / .Q.dpft applies the parted attribute
    };

.log.lvl:`DEBUG;
testMeta:{[tab;met]
    .log.info"Testing ",string[tab]," table meta";
    .log.debug"Table ",string[tab]," meta: ";
    .log.debug m:meta tab;
    if[not m~met;'.log.error"Table ",string[tab]," meta test failed!"];
    };

.log.warn"Force removing directory: ",.Q.s1 dst:`:hdb;
.util.recurseDel dst;

saveTab each asc .z.d-til 2;

.log.system"l ",1_string dst;
.log.system"l ../dbmaint.q";

met:([c:`date`symbolColumn`timespanColumn`listColumn`booleanColumn`guidColumn`byteColumn`byteNestedColumn`shortColumn`longNestedColumn`floatColumn`floatNestedColumn`charColumn] t:"dsn bgxXhJfFc"; f:`; a:``p```````````);
testMeta[`tab;met];

.log.info"Table tab columns: ";
.log.info columns:listCols[thisDb;`tab];
findCol[thisDb;`tab]each columns;

castCol[thisDb;`tab;`shortColumn;`long];
renameCol[thisDb;`tab;`shortColumn;`longColumn];
update c:`longColumn,t:"j"from`met where c=`shortColumn;
copyCol[thisDb;`tab;`longColumn;`longColumn2];
`met insert`longColumn2,"j",``;

addCol[thisDb;`tab;`symbolColumn2;`g#n?`MSFT`AMZN`C`MET`JPM`WFC];
met,update a:`g from select from met where c=`symbolColumn;
`met insert`symbolColumn2,"s",``g;
addCol[thisDb;`tab;`symbolNestedColumn;enlist`nested`symbols];
`met insert`symbolNestedColumn,"S",``;

testMeta[`tab;met];

clearAttrCol[thisDb;`tab;`symbolColumn2];
update a:` from`met where c=`symbolColumn2;
deleteCol[thisDb;`tab;`longColumn2];
delete from`met where c=`longColumn2;

funcCol[thisDb;`tab;`byteNestedColumn;asc!'[-9]@];
renameCol[thisDb;`tab;`byteNestedColumn;`frombyteNestedColumn];
update c:`frombyteNestedColumn,t:"j",a:`s from`met where c=`byteNestedColumn;

testMeta[`tab;met];

columns:listCols[thisDb;`tab];
reorderCols[thisDb;`tab;rev:reverse columns];
met:(1#met),reverse 1_met;

testMeta[`tab;met];

setAttrCol[thisDb;`tab;`booleanColumn;`g];
update a:`g from`met where c in`booleanColumn;
setAttrCol[thisDb;`tab;`frombyteNestedColumn;`u];
update a:`u from`met where c in`frombyteNestedColumn;
renameTab[`:.;`tab;`tab2];

addTab[thisDb;`trade;([] time:asc n?00:00:00.000000000; sym:`g#n?`ABC`DEF`GHI; side:n?"BS"; qty:n?1000; tid:n?til 4)];

.log.system"l .";

testMeta[`tab2;met];

met:([c:`date`time`sym`side`qty`tid] t:"dnscjj"; f:`; a:`);
testMeta[`trade;met];

select from tab2 where date=last date;
select from trade where date=last date;

.log.info"Test passed";

.log.system"cd ..";
.log.info"Tearing down";
.log.warn"Force removing directory: ",.Q.s1 dst:`:hdb;
.util.recurseDel dst;
