/################
/# TP Log utils #
/################

// TODO: Add a bkp option and check if linux
truncate:.tplog.truncate:{[tplog] if[7h~type chunk:-11!(-2;tplog);.log.system"truncate ",.util.strPath[tplog]," --size=",string last chunk]};
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
