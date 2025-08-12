// INFO: https://code.kx.com/q4m3/14_Introduction_to_Kdb+/#143-partitioned-tables
/ Script to create mock int, date, month and year partitioned databases

.part.numTrade:1000; / Total number of trades
.part.numPart:10;    / Total number of partitions
.part.rmForce:1b;    / Force remove destination path if it already exists
.part.dest:`:part;   / Destination path

.part.mockdata:([] sym:.part.numTrade?`AAPL`IBM`GE`GOOG; price:50+.part.numTrade?50f; size:.part.numTrade?.part.numTrade);
.part.domain:`int`date`month`year;
.part.genTime:.part.domain!(
    {.z.d-(x?`time$60*60*1000*til y)+x?0D01-1};
    {(x?.z.d-til y)+x?1D-1};
    {(x?(`month$.z.d)-til y)+x?28D};
    {(x?"D"$string[(`year$.z.d)-til y],\:".01.01")+x?365D-1});
.part.hour:{`int$sum 24 1*`date`hh$\:x};
.part.whereClause:.part.domain!(.part.hour;`date$;{`month$`date$x};{`year$`date$x});

.part.genData:{
    if[.part.rmForce&.util.exists .part.dest;.log.warn"Force removing directory: ",.Q.s1 .part.dest;.util.recurseDel .part.dest];
    {[domain]
        -1"";
        .log.info"Generating mock ",.Q.s1[domain]," partitioned hdb: ",.Q.s1 dir:.Q.dd[.part.dest;domain,`hdb];
        data:update time:.part.genTime[domain][.part.numTrade;.part.numPart]from .part.mockdata;
        {[domain;dir;data;part]
            `trade set`sym`time xasc?[data;enlist(=;part;(.part.whereClause domain;`time));0b;()];
            .log.info"Saving trade table to partition: ",string part;
            .Q.dpft[dir;part;`sym;`trade];
            }[domain;dir;data]each exec asc distinct .part.whereClause[domain]time from data;
        }each .part.domain;
    };
