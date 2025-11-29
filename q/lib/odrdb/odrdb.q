/###############
/# On-disk RDB #
/###############

.odrdb.buffer:()!();
.odrdb.flush.rowLimit:100000;
.odrdb.flush.interval:0D00:05;
.odrdb.flush.time:.z.p;

/ Schema definitions
/.odrdb.buffer[`trade]:([] time:`timestamp$(); sym:`symbol$(); price:`float$(); size:`long$(); exchange:`symbol$());
/.odrdb.buffer[`quote]:([] time:`timestamp$(); sym:`symbol$(); bid:`float$(); ask:`float$(); bsize:`long$(); asize:`long$());

.odrdb.path:`:tmp/rdb;

/ Data received will be inserted to the buffer table instead of the main table
.odrdb.upd:{[table;data] .Q.dd[`.odrdb.buffer;table]insert data;};
.odrdb.ts:{.odrdb.flushTables[]};

// NOTE: No flush on .z.ps to maintain performance for high-frequency async updates from TP
.odrdb.overrideHandlers:{
    .z.oldPg:$[.util.exists`.z.pg;.z.pg;value];
    .z.pg:{.odrdb.flushTables[];.z.oldPg x};
    / Override .z.ph and .z.pp only if defined
    if[.util.exists`.z.ph;.z.oldPh:.z.ph;.z.ph:{.odrdb.flushTables[];.z.oldPh x}];
    if[.util.exists`.z.pp;.z.oldPp:.z.pp;.z.pp:{.odrdb.flushTables[];.z.oldPp x}];
    };

.odrdb.init:{
    .log.info"Initializing on-disk RDB";
    .odrdb.overrideHandlers[];
    / Init main, buffer and splayed tables
    .odrdb.flushTable[1b]each key .odrdb.buffer;
    `upd set .odrdb.upd;
    .z.ts:.odrdb.ts;
    .log.system"t 1000";
    };

/ Apply sorted attribute to time column
.odrdb.sortedTime:{$[`time in cols x;![;();0b;(enlist`time)!enlist(`s#;`time)];]x};

.odrdb.initSchema:{[schema]
    / Delete date column from RDB schema
    schema:delete date from 0#schema;
    / Reorder time and sym columns
    (`time`sym inter cols schema)xcols schema};

.odrdb.logFlush:{[table;rows]
    .log.info"Flushing table: [",string[table],"]";
    {[table;rows;st;nil]
        .log.info"Flushed table: [",string[table],"]. ",string[rows]," rows in ",string .z.p-st;
        }[table;rows;.z.p]};

/ Update main, buffer and splayed table
.odrdb.flushTable:{[init;table]
    data:.odrdb.sortedTime$[init;.odrdb.initSchema;].odrdb.buffer table;
    logFlush:$[init;;.odrdb.logFlush[table;count data]];
    splayedPath:.Q.dd[.odrdb.path;table,`];
    / Enumerate table and set or upsert to splayed table
    $[init;set;upsert][splayedPath;.Q.en[.odrdb.path;data]];
    / Memory-map table from disk
    if[init;table set get splayedPath];
    / Set (clear) buffer
    .odrdb.buffer[table]:0#data;
    logFlush[]};

.odrdb.flushTablesExeedRowLimit:{[rowLimit] .odrdb.flushTable[0b]each where rowLimit<count each .odrdb.buffer;};

.odrdb.flushTables:{
    / Flush tables exceeding row limit
    .odrdb.flushTablesExeedRowLimit .odrdb.flush.rowLimit;
    / Flush tables with data when exceed interval
    if[.odrdb.flush.interval<.z.p-.odrdb.flush.time;
        .odrdb.flushTablesExeedRowLimit 0;
        .odrdb.flush.time:.z.p;
        ];
    };
