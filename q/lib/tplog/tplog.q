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
    @[.tplog.replay;(chunks;tplog);{}];
    resetPs[];
    hclose h;
    l};

/
/ Replay tplog from n-th index
/ @param tplog - same params as -11!
replay:.tplog.replay:{[index;tplog]
    index|:.u.i:0;
    oldUpd:upd;
    if[index<>.u.i;
        `upd set{[tab;data;index;oldUpd]
            if[index~.u.i;`upd set oldUpd];
            .u.i+:1}[;;index-1;oldUpd];
        ];
    res:-11!tplog;
    `upd set oldUpd;
    res};
