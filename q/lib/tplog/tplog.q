/################
/# TP Log utils #
/################

.tplog.replay:-11!;
.tplog.goodTil:{.tplog.replay -2,x};
.tplog.goodItems:{first .tplog.goodTil x};
.tplog.goodCount:{last .tplog.goodTil x};
.tplog.valid:{(hcount x)=.tplog.goodCount x};
.tplog.replayGood:{.tplog.replay(.tplog.goodItems x;x)};

.tplog.i.truncatedName:{.util.strPath[x],".truncated"};

/ Truncate corrupt TP Log using generic unix system tool
/ @param tplog - sym - corrupt TP Log file path
/ @param bkp - boolean - 1b to backup, 0b to overwrite
osTruncate:.tplog.os.truncate:{[tplog;bkp]
    if[1=count valid:.tplog.goodTil tplog;:{}.log.info"TP Log is not corrupted"];
    length:string last valid;
    tplogStr:.util.strPath tplog;
    .log.system$[bkp;
        "head -c ",length," ",tplogStr," > ",.tplog.i.truncatedName tplogStr;
        "truncate ",tplogStr," --size=",length]};

/ Truncate corrupt TP Log
/ @param tplog - sym - corrupt TP Log file path
truncate:.tplog.truncate:{[tplog]
    if[1=count valid:.tplog.goodTil tplog;:{}.log.info"TP Log is not corrupted"];
    h:hopen(l:`$.tplog.i.truncatedName tplog)set();
    chunks:first valid;
    resetPs:$[.util.exists`.z.ps;[`oldPs set .z.ps;{.z.ps:oldPs}];{system"x .z.ps"}];
    .z.ps:{[h;m]h enlist m}h;
    @[.tplog.replay;(chunks;tplog);{.log.error"Error replaying tplog: ",x}];
    resetPs[];
    hclose h;
    l};

/ Replay number of chunks of TP Log from offset chunk
/ @param offset - number - offset chunk from start of TP Log
/ @param num - number - number of chunks to replay from offset
/ @param tplog - sym - TP Log file path
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

// INFO: https://github.com/DataIntellectTech/TorQ/blob/master/code/common/tplogutils.q
// WARN: Logic may break if (`upd;...) is in the messages

.tplog.i.header:8#-8!(`upd;`table;());          / Header to build deserializable message
.tplog.i.updMsg:`char$10#8_-8!(`upd;`table;()); / Firt part of TP update (upd) messages
.tplog.i.chunk:10*1024*1024;                    / Default size (10MB) of chunk to read
.tplog.i.maxChunk:8*.tplog.i.chunk;             / Prevent single read from exceeding max chunk size

/ Fix corrupt TP Log with bad messages in the middle
/ @param tplog - sym - corrupt TP Log file path
.tplog.fix:{[tplog]
    if[1=count valid:.tplog.goodTil tplog;:{}.log.info"TP Log is not corrupted"];
    h:hopen(l:.q.Hsym .util.strPath[tplog],".good")set();
    .log.info"Fixing TP Log in chunks";
    .tplog.i.fix[tplog;h]over`start`size!0,.tplog.i.chunk;
    .log.info"Fixed TP Log";
    hclose h;
    l};

/ @param tplog - sym - corrupt TP Log file path
/ @param h - int - handle of the new TP Log
/ @param d - dict - dictionary with offset and chunk size to read TP Log
.tplog.i.fix:{[tplog;h;d]
    .log.info"Reading TP Log with offset and chunk size: [",.Q.s1[offsetLength:d`start`size],"] bytes";
    bytes:read1 tplog,offsetLength;
    / Search for first part of TP upd messages
    updPos:ss[`char$bytes;.tplog.i.updMsg];
    / Nothing found in this chunk
    if[not count updPos;
        / EOF - complete
        if[hcount[tplog]<=sum offsetLength;:d];
        / Continue to next chunk
        :@[d;`start;+;d`size]];
    / Split bytes into messages
    msg:updPos _bytes;
    / Message sizes as bytes
    msgSize:0x0 vs'`int$8+msgCnt:count each msg;
    / Set message size at correct part of header
    header:@[.tplog.i.header;7 6 5 4;:;]each msgSize;
    / Try to deserialize each message
    data:@[(1b;)@-9!;;(0b;)@]each header,'msg;
    / Write good data to the new TP Log
    h data[;1]where good:data[;0];
    / All bad data
    if[not any good;
        / Exceeds max chunk size, give up
        if[.tplog.i.maxChunk<=d`size;:@[d;`start`size;:;(sum offsetLength;.tplog.i.chunk)]];
        / Try to read a bigger chunk
        :@[d;`size;*;2]];
    / Move start to the end of the last good message
    start:d[`start]+sums[msgCnt]last where good;
    @[d;`start`size;:;(start;.tplog.i.chunk)]};
