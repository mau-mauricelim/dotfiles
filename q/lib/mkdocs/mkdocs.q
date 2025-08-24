// INFO: Inspired by https://github.com/KxSystems/help
/ Make docs q script from ./docs/*.md files

.mkdocs.indent:4;
.mkdocs.header:(
    "// NOTE: This q script was generated using mkdocs.q";
    "";
    "/########";
    "/# Docs #";
    "/########";
    "";
    ".docs.refs:.docs.libs:()!();";
    ".docs.docs:{[name]\n    if[not name in key .docs.refs;.log.warn\"Docs name not found. Please add to docs.\";.log.info\"Available docs:\",.log.plainText .docs.refs;:(::)];\n    .util.stdout .docs.libs name};");
.mkdocs.footer:(
    "";
    "/ Set globals for easy access";
    "refs:.docs.refs;";
    "docs:.docs.docs;");

.mkdocs.docFmt:(
    "+------------- Start of file -------------+";
    "|# Title            <--- First line       |";
    "|                   <--- Second line empty|";
    "|```txt             <--- Third line       |";
    "|Example content                          |";
    "|...                                      |";
    "|```                <--- Last line        |";
    "+-------------- End of file --------------+")
.mkdocs.chkFmt:{[filePath;content]
    ok:first[content]like"# *";
    ok&:content[1]~"";
    ok&:content[2]~"```txt";
    ok&:last[content]~"```";
    if[not ok;
        .log.warn"The format of the docs file is wrong: ",.util.strPath filePath;
        .log.info"The format should follow: ";
        -1 .mkdocs.docFmt]};

.mkdocs.mkhead:{[k;title]
    ("";
    ".docs.refs[`",k,"]:",(-3!title),";";
    ".docs.libs[`",k,"]:(")};
.mkdocs.mkdoc:{[h;path;file]
    content:read0 filePath:.Q.dd[path;file];
    .log.info"Making docs from: ",.util.strPath filePath;
    .mkdocs.chkFmt[filePath;content];
    title:2_first content;
    body:-1_3_content;
    body:.mkdocs.i.indent,/:(-3!'body),'";";
    body:@[body;-1+count body;{(-1_x),");"}];
    k:string .Q.id first` vs file;
    head:.mkdocs.mkhead[k;title];
    h head,body;};

/ Custom docsPath and saveFile
.mkdocs.i.mkdocs:{[docsPath;saveFile]
    .log.info"DOCSPATH: ",docsPathStr:.util.strPath docsPath:.q.Hsym docsPath;
    .log.info"SAVEFILE: ",saveFileStr:.util.strPath saveFile:.q.Hsym saveFile;

    / Ensure full console size
    .term.full[];

    if[not .util.exists docsPath;.log.error"DOCSPATH not found: ",docsPathStr;:(::)];
    docsFile:key[docsPath]except`template.md;
    docsFile@:where lower[docsFile]like"*.md";
    if[not count docsFile;.log.error"No markdown files found in DOCSPATH";:(::)];

    @[hdel;.mkdocs.saveFile:saveFile;{}];
    .log.info"Making docs file: ",saveFileStr;
    h:neg hopen .mkdocs.saveFile;

    .mkdocs.i.indent:.mkdocs.indent#"";
    h .mkdocs.header;
    .mkdocs.mkdoc[h;docsPath]'[docsFile];
    h .mkdocs.footer;
    hclose abs h;
    /-1 read0 .mkdocs.saveFile;
    };

/ Main
/ Default docsPath and saveFile
mkdocs:.mkdocs.mkdocs:{
    scriptPath:.util.getScriptPath{};
    dirname:.util.dirname scriptPath;
    docsPath:dirname,"/docs";
    saveFile:docsPath,".q";
    .mkdocs.i.mkdocs[docsPath;saveFile];
    };

/ If file is ran as a script
/ q mkdocs.q docs ../docs/docs.q
if[.util.isStartupFile{};
    if[2>count .Q.x;exit -2"Usage: q ",(string .z.f)," DOCSPATH SAVEFILE"];
    .mkdocs.i.mkdocs . .Q.x 0 1;
    exit 0];
