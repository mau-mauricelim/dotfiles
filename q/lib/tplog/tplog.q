/################
/# TP Log utils #
/################
// TODO: https://code.kx.com/q/kb/logging/#replay-from-corrupt-logs
//       https://github.com/simongarland/tickrecover/blob/master/recover.q

// TODO: Add a bkp option and check if linux
truncate:.tplog.truncate:{[tplog] if[7h~type chunk:-11!(-2;tplog);.log.system"truncate ",.util.strPath[tplog]," --size=",string last chunk]};

// TODO: In progress
recover:{[tplog]
    if[1=count chunks:-11!(-2;tplog);:{}.log.info"TP Log is not corrupted"];
    h:hopen(l:`$string[tplog],".recovered")set();
    chunks:first chunks;
    reset:$[.util.exists`.z.ps;[`oldPs set .z.ps;{.z.ps:oldPs}];{system"x .z.ps"}];
    .z.ps:{x enlist y}h;
    @[-11!;(chunks;tplog);{}];
    reset[];
    hclose h};

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
