{
    .lib.require`qute;
    scriptPath:.util.getScriptPath{};
    .qute.loadTests .q.Hsym .util.dirname scriptPath;
    .qute.runTests[];
    exit 0}[];
