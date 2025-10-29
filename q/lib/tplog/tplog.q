/################
/# TP Log utils #
/################
// TODO: https://code.kx.com/q/kb/logging/#replay-from-corrupt-logs
//       https://github.com/simongarland/tickrecover/blob/master/recover.q
//       https://github.com/DataIntellectTech/TorQ/blob/master/code/common/tplogutils.q

.tplog.replay:-11!;
.tplog.verify:{.tplog.replay -2,x};

.tplog.i.truncatedName:{.util.strPath[x],".truncated"};

/ Truncate corrupt TP Log using generic unix system tool
.tplog.os.truncate:{[tplog;bkp]
    if[1=count valid:.tplog.verify tplog;:{}.log.info"TP Log is not corrupted"];
    length:string last valid;
    tplogStr:.util.strPath tplog;
    .log.system$[bkp;
        "head -c ",length," ",tplogStr," > ",.tplog.i.truncatedName tplogStr;
        "truncate ",tplogStr," --size=",length]};

/ Truncate corrupt TP Log
truncate:.tplog.truncate:{[tplog]
    if[1=count valid:.tplog.verify tplog;:{}.log.info"TP Log is not corrupted"];
    h:hopen(l:`$.tplog.i.truncatedName tplog)set();
    chunks:first valid;
    resetPs:$[.util.exists`.z.ps;[`oldPs set .z.ps;{.z.ps:oldPs}];{system"x .z.ps"}];
    .z.ps:{[h;m]h enlist m}h;
    @[.tplog.replay;(chunks;tplog);{.log.error"Error replaying tplog: ",x}];
    resetPs[];
    hclose h;
    l};

/ Replay number of chunks of TP Log from offset chunk
/ @return - number of chunks executed
replayFromOffset:.tplog.replayFromOffset:{[offset;num;tplog]
    if[any 0>offset,num;{}.log.error"Number of chunks and offset chunk must be a non-negative number"];
    offset|:.u.i:0;
    num|:.u.n:0;
    `oldUpd set upd;
    `upd set{[tab;data;bounds]
        if[.u.i within bounds;oldUpd[tab;data];.u.n+:1];
        .u.i+:1}[;;-1+offset+0,num-1];
    resetUpd:{`upd set oldUpd};
    res:@[.tplog.replay;tplog;{.log.error"Error replaying tplog: ",x}];
    resetUpd[];
    .u.n};
