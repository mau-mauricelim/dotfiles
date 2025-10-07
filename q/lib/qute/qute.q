/################
/# q unit tests #
/################
// INFO: Inspired by https://github.com/simongarland/k4unit

.qute.cfg.delim:"|";
.qute.cfg.failOnError:1b;
.qute.cfg.saveFile:`:qutr.dsv;
/ Save method affects how repeated (`beforeeach`aftereach action) code run results are saved: `all/`last
.qute.cfg.saveMethod:`all;

/ Test Definitions
qutd:([]action:`symbol$();minver:`float$();code:`symbol$();repeat:`int$();ms:`int$();bytes:`long$();comment:`symbol$();file:`symbol$();line:`int$());
/ Test Results
qutr:.Q.ff[qutd;([]msx:`int$();bytesx:`long$();okms:`boolean$();okbytes:`boolean$();ok:`boolean$();valid:`boolean$();error:();timestamp:`datetime$();result:())];

.qute.i.definitionTypes:exec"*"^t from meta delete file,line from qutd;
.qute.i.resultTypes:exec"*"^t from meta qutr;

.qute.actions:`beforeany`beforeeach`before`run`true`fail`after`aftereach`afterall;

.qute.findTestFiles:{[path]
    if[not .util.exists path;.log.errorNotFound path;:()];
    filepath:$[.util.isDir path;.util.recurseDirNoHidden;(),]path;
    filepath where{last[` vs x]like"qute.*.dsv"}each filepath};

.qute.i.loadTestFile:{[path]
    .log.info"Loading tests from file: ",(.Q.s1 path)," to qutd";
    tests:(.qute.i.definitionTypes;enlist .qute.cfg.delim)0:path;
    / Set defaults
    tests:update lower action,minver|0,repeat|1i,ms|0i,bytes|0,file:path,line:`int$2+i from tests;
    tests:select from tests where minver<=.z.K,action in .qute.actions;
    / Remove previous tests loaded from the same path if any
    `qutd set(delete from qutd where file=path),tests;
    .log.info"Loaded ",string[cnt:count tests]," tests from file: ",(.Q.s1 path)," to qutd";
    cnt};

qult:.qute.loadTests:{[path]
    .log.info"Loading tests to qutd";
    files:raze .qute.findTestFiles each path;
    if[not count files;:{}.log.warn"No test files found to load: ",.Q.s1 path];
    cnt:.qute.i.loadTestFile each files;
    .log.info"Loaded ",string[sum cnt]," tests to qutd";
    / Sort by file, custom action order - preserves run, true fail orders
    replaceAssert:{?[x in`run`true`fail;`assert;x]};
    `qutd set`file xasc qutd iasc replaceAssert[.qute.actions]?replaceAssert qutd`action;};

qurt:.qute.runTests:{
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
    .qute.testSummary[]};

.qute.testSummary:{
    total:count qutr;
    if[total~count quts.oks[];:{}.log.info"All tests passed"];
    .log.error string[count notOks:quts.notOks[]]," tests failed:";
    .log.error notOks;};

.qute.i.runCodeError:`.qute.i.runCodeError;
.qute.i.runCodeErrorTrap:{[action;idx;error]
    if[action<>`fail;
        .log.error(`file`line`action`code#qutd idx),([error]);
        if[.qute.cfg.failOnError;'.qute.i.runCodeError]];
    (.qute.i.runCodeError;error)};

.qute.i.runCode:{[action;code;repeat;ms;bytes;idx]
    evalCode:"ts:",string[repeat]," .qute.i.runCodeResult: ",string code;
    ts:@[system;evalCode;.qute.i.runCodeErrorTrap[action;idx]];
    ok:$[failed:.qute.i.runCodeError~first ts;
        [error:last ts;
            ts:0 0;
            .qute.i.runCodeResult:();
            action in`fail];
        [error:"";
            $[action=`true;.qute.i.runCodeResult~1b;action<>`fail]]];
    msx:first ts;
    bytesx:last ts;
    okms:$[ms;ms>msx;1b];
    okbytes:$[bytes;bytes>bytesx;1b];
    ([msx;bytesx;okms;okbytes;ok;valid:not failed;error;timestamp:.z.Z;result:enlist .qute.i.runCodeResult;idx])};

.qute.i.encodeDelim:";";
.qute.i.encodeColumn:{.qute.i.encodeDelim sv string -8!x}each;
.qute.i.decodeColumn:{-9!"X"$.qute.i.encodeDelim vs x}each;
.qute.saveTestResults:{.qute.cfg.saveFile 0:.qute.cfg.delim 0:update .qute.i.encodeColumn result from qutr};
// WARN: This overrides qutr
.qute.loadTestResults:{`qutr set update .qute.i.decodeColumn result from(.qute.i.resultTypes;enlist .qute.cfg.delim)0:.qute.cfg.saveFile};

/ Test Summary functions
quts:([
    oks    :{select from qutr where okms,okbytes,ok};
    notOks :{select from qutr where not okms&okbytes&ok};
    ok     :{select from qutr where ok};
    notOk  :{select from qutr where not ok};
    slow   :{select from qutr where not okms};
    big    :{select from qutr where not okbytes};
    invalid:{select from qutr where not valid}]);
