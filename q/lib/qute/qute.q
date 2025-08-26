/################
/# q unit tests #
/################
// INFO: Inspired by https://github.com/simongarland/k4unit

.qute.delim:"|";
.qute.verbose:0b;
.qute.debug:0b;
.qute.saveFile:`:QUTR.dsv;
/ Save method affects how repeated (`beforeeach`aftereach action) code run results are saved
.qute.saveMethod:`last; /`all

QUT:([]action:`symbol$();minver:`float$();code:`symbol$();repeat:`int$();ms:`int$();bytes:`long$();comment:`symbol$();file:`symbol$();line:`int$());
QUTR:.Q.ff[QUT;([]msx:`int$();bytesx:`long$();okms:`boolean$();okbytes:`boolean$();ok:`boolean$();valid:`boolean$();error:();timestamp:`datetime$();result:())];
.qute.qut.types:exec"*"^t from meta delete file,line from QUT;
.qute.qut.actions:`beforeany`beforeeach`before`run`true`fail`after`aftereach`afterall;

.qute.findDsv:{[path] filepath where{last[` vs x]like"qute.*.dsv"}each filepath:.util.recurseDirNoHidden path};
.qute.loadTest:{[path]
    qut:(.qute.qut.types;enlist .qute.delim)0:path;
    / Set defaults
    qut:update lower action,minver|0,repeat|1i,ms|0i,bytes|0,file:path,line:`int$2+i from qut;
    QUT,:qut:select from qut where minver<=.z.K,action in .qute.qut.actions;
    .log.info"Loaded ",string[cnt:count qut]," tests from: ",-3!path;
    cnt};

.qute.loadTests:{[path]
    .log.info"Loading tests from ",(-3!path)," to QUT";
    cnt:.qute.loadTest each .qute.findDsv path;
    .log.info"Loaded ",string[sum cnt]," tests to QUT";
    / Sort by file, custom action order - preserves run, true fail orders
    replaceAssert:{?[x in`run`true`fail;`assert;x]};
    `QUT set`file xasc QUT iasc replaceAssert[.qute.qut.actions]?replaceAssert QUT`action;};

.qute.runTests:{
    if[not count QUT;.log.warn"No tests found in QUT. Please load tests first.";:(::)];
    .log.info"Running ",string[count QUT]," tests from QUT";
    qutr :exec .qute.runCode'[action;code;repeat;ms;bytes;i]from QUT where action=`beforeany;
    / Loop through each test files
    qutr,:raze{
        qutr :exec .qute.runCode'[action;code;repeat;ms;bytes;i]from QUT where action=`beforeeach;
        qutr,:exec .qute.runCode'[action;code;repeat;ms;bytes;i]from QUT where file=x,action in`before`run`true`fail`after;
        qutr,:exec .qute.runCode'[action;code;repeat;ms;bytes;i]from QUT where action=`aftereach;
        qutr}each exec distinct file from QUT;
    qutr,:exec .qute.runCode'[action;code;repeat;ms;bytes;i]from QUT where action=`afterall;
    .log.info"Finished running tests from QUT";
    qutr :$[.qute.saveMethod~`last;
        (update idx:i from QUT)lj select by idx:i from qutr;
        qutr lj select by idx:i from QUT];
    `QUTR set?[qutr;();0b;c!c:cols QUTR];
    .log.info"Test results are stored in QUTR";
    QUTR};

.qute.runCode:{[action;code;repeat;ms;bytes;i]
    error:"";
    .qute.i.runCode:();
    // TODO: no error trap if fail fast/debug?
    ts:@[system;"ts:",string[repeat]," .qute.i.runCode: ",string code;{(`.qute.runCode.error;x)}];
    ok:$[failed:`.qute.runCode.error~first ts;
        [error:last ts;
            ts:0 0;
            action in`fail];
        $[action=`true;.qute.i.runCode~;]1b];
    msx:first ts;
    bytesx:last ts;
    okms:$[ms;not msx>ms;1b];
    okbytes:$[bytes;not bytesx>bytes;1b];
    `msx`bytesx`okms`okbytes`ok`valid`error`timestamp`result`idx!
    (msx;bytesx;okms;okbytes;ok;not failed;error;.z.Z;enlist .qute.i.runCode;i)};

// TODO: Add a testSummary function
/ Add logging
.qute.testSummary:{
    .qute.qutr.testFile:exec distinct file from QUTR;
    .qute.qutr.slow:select from QUTR where not okms;
    .qute.qutr.slowFile:exec distinct file from .qute.qutr.slow;
    .qute.qutr.big:select from QUTR where not okbytes;
    .qute.qutr.bigFile:exec distinct file from .qute.qutr.big;
    .qute.qutr.err:select from QUTR where not ok;
    .qute.qutr.errFile:exec distinct file from .qute.qutr.err;
    .qute.qutr.invalid:select from QUTR where not valid;
    .qute.qutr.invalidFile:exec distinct file from .qute.qutr.invalid;
    / all ok
    / any not ok
    .qute.qutr};

.qute.loadTests`:lib
.qute.runTests[]
