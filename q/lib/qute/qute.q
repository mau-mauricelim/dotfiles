/################
/# q unit tests #
/################
// INFO: Inspired by https://github.com/simongarland/k4unit

.qute.cfg.delim:"|";
.qute.cfg.verbose:0b;
// TODO: Check
.qute.cfg.failOnError:1b;
.qute.cfg.saveFile:`:qutr.dsv;
/ Save method affects how repeated (`beforeeach`aftereach action) code run results are saved
.qute.cfg.saveMethod:`last; /`all

/ Test Definitions
qutd:([]action:`symbol$();minver:`float$();code:`symbol$();repeat:`int$();ms:`int$();bytes:`long$();comment:`symbol$();file:`symbol$();line:`int$());
/ Test Results
qutr:.Q.ff[qutd;([]msx:`int$();bytesx:`long$();okms:`boolean$();okbytes:`boolean$();ok:`boolean$();valid:`boolean$();error:();timestamp:`datetime$();result:())];

.qute.actions:`beforeany`beforeeach`before`run`true`fail`after`aftereach`afterall;

.qute.findTestFiles:{[path]
    if[not .util.exists path;.log.error(-3!path),": No such file or directory";:()];
    filepath:$[.util.isDir path;.util.recurseDirNoHidden;(),]path;
    filepath where{last[` vs x]like"qute.*.dsv"}each filepath};

.qute.i.types:exec"*"^t from meta delete file,line from qutd;
.qute.i.loadTestFile:{[path]
    .log.info"Loading tests from file: ",(-3!path)," to qutd";
    tests:(.qute.i.types;enlist .qute.cfg.delim)0:path;
    / Set defaults
    tests:update lower action,minver|0,repeat|1i,ms|0i,bytes|0,file:path,line:`int$2+i from tests;
    qutd,:tests:select from tests where minver<=.z.K,action in .qute.actions;
    / Ensure no duplicates when reloading tests
    `qutd set?[select by file,line from qutd;();0b;c!c:cols qutd];
    .log.info"Loaded ",string[cnt:count tests]," tests from file: ",(-3!path)," to qutd";
    cnt};

.qute.loadTests:{[path]
    .log.info"Loading tests to qutd";
    files:raze .qute.findTestFiles each path;
    if[not count files;:{}.log.warn"No test files found to load: ",-3!path];
    cnt:.qute.i.loadTestFile each files;
    .log.info"Loaded ",string[sum cnt]," tests to qutd";
    / Sort by file, custom action order - preserves run, true fail orders
    replaceAssert:{?[x in`run`true`fail;`assert;x]};
    `qutd set`file xasc qutd iasc replaceAssert[.qute.actions]?replaceAssert qutd`action;};

.qute.runTests:{
    if[not count qutd;:{}.log.warn"No tests found in qutd, please load tests first."];
    .log.info"Running ",string[count qutd]," tests from qutd";
    result :exec .qute.i.runCode'[action;code;repeat;ms;bytes;i]from qutd where action=`beforeany;
    / Loop through each test files
    result,:raze{
        result :exec .qute.i.runCode'[action;code;repeat;ms;bytes;i]from qutd where action=`beforeeach;
        result,:exec .qute.i.runCode'[action;code;repeat;ms;bytes;i]from qutd where file=x,action in`before`run`true`fail`after;
        result,:exec .qute.i.runCode'[action;code;repeat;ms;bytes;i]from qutd where action=`aftereach;
        result}each exec distinct file from qutd;
    result,:exec .qute.i.runCode'[action;code;repeat;ms;bytes;i]from qutd where action=`afterall;
    .log.info"Finished running tests from qutd";
    result :$[.qute.cfg.saveMethod~`last;
        (update idx:i from qutd)lj select by idx:i from result;
        result lj select by idx:i from qutd];
    `qutr set?[result;();0b;c!c:cols qutr];
    .log.info"Test results are stored in qutr";
    qutr};

.qute.i.runCode:{[action;code;repeat;ms;bytes;i]
    error:"";
    .qute.i.runCodeResult:();
    errTrap:{[action;err]
        res:(`.qute.runCode.error;err);
        if[.qute.cfg.failOnError&action<>`fail;'res];
        res}action;
    ts:@[system;"ts:",string[repeat]," .qute.i.runCodeResult: ",string code;errTrap];
    ok:$[failed:`.qute.runCode.error~first ts;
        [error:last ts;
            ts:0 0;
            action in`fail];
        $[action=`true;.qute.i.runCodeResult~;]1b];
    msx:first ts;
    bytesx:last ts;
    okms:$[ms;not msx>ms;1b];
    okbytes:$[bytes;not bytesx>bytes;1b];
    `msx`bytesx`okms`okbytes`ok`valid`error`timestamp`result`idx!
    (msx;bytesx;okms;okbytes;ok;not failed;error;.z.Z;enlist .qute.i.runCodeResult;i)};

/ Test Summary
quts:(!). flip(
    (`oks    ;{select from qutr where okms,okbytes,ok});
    (`notOks ;{select from qutr where not okms&okbytes&ok});
    (`ok     ;{select from qutr where ok});
    (`notOk  ;{select from qutr where not ok});
    (`slow   ;{select from qutr where not okms});
    (`big    ;{select from qutr where not okbytes});
    (`invalid;{select from qutr where not valid}))

/
.qute.loadTests`:lib
.qute.runTests[]
