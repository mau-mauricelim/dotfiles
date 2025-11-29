.test.table:`trade`quote;
.test.n:100000000;
/ Test function to generate and insert data
.test.updData:{
    n:.test.n;
    upd[`trade;([] time:.z.d+asc n?.z.n; sym:n?`AAPL`GOOGL`MSFT`AMZN`TSLA`FB`NFLX`NVDA; price:100+n?100.0; size:100*1+n?100; exchange:n?`NYSE`NASDAQ`ARCA)];
    upd[`quote;([] time:.z.d+asc n?.z.n; sym:n?`AAPL`GOOGL`MSFT`AMZN`TSLA`FB`NFLX`NVDA; bid:100+n?100.0; ask:100.1+n?100.0; bsize:100*1+n?100; asize:100*1+n?100)];
    };
.test.usedMem:{.Q.wh[]`used};
.test.structure:{system"c 10 50";(.Q.s1 get@)each .test.table};
/ Test query time and space
.test.query:{{system"t select avg price by sym from trade"}each til 5};

.log.info"Initializing in-memory RDB";
trade:([] time:`timestamp$(); sym:`symbol$(); price:`float$(); size:`long$(); exchange:`symbol$());
quote:([] time:`timestamp$(); sym:`symbol$(); bid:`float$(); ask:`float$(); bsize:`long$(); asize:`long$());
upd:insert;
.test.mem.rdb:(),.test.usedMem[];
.test.updData[];
.test.mem.rdb,:.test.usedMem[];
.test.s1.rdb:.test.structure[];
.test.time.rdb:.test.query[];

/ On-disk RDB
.odrdb.buffer[`trade]:trade;
.odrdb.buffer[`quote]:quote;
.odrdb.init[];
.Q.gc[];
.test.mem.odrdb:(),.test.usedMem[];
.test.updData[];
.z.ts[];
.test.mem.odrdb,:.test.usedMem[];
.test.s1.odrdb:.test.structure[];
.test.time.odrdb:.test.query[];

/ Test results
\c 10 200
.log.banner"Showing test results";
.log.info"Memory statistics:";
show([mem:`before`after] .test.mem.rdb; .test.mem.odrdb);

.log.info"Table structure:";
show([s1:.test.table] .test.s1.rdb; .test.s1.odrdb);

.log.info"Performance statistics:";
show([time:1+til count .test.time.rdb] .test.time.rdb; .test.time.odrdb);
