/ Usage: q runTests.q [-lib q dotx maths]
{
    .lib.require`qute;
    scriptPath:.util.getScriptPath{};
    testPath:rootPath:.q.Hsym .util.dirname scriptPath;
    if[count lib:`$.Q.opt[.z.x]`lib;
        / q lib is reserved for root test directory
        testPath:.Q.dd[rootPath]each`lib,'lib except`q;
        if[`q in lib;testPath,:.Q.dd[rootPath;`test]]];
    .qute.loadTests testPath;
    .qute.runTests[];
    exit 0}[];
