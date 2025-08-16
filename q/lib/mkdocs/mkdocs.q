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
    "refs:.docs.refs:.docs.libs:()!();";
    "docs:.docs.docs:{[name]\n    if[not name in key .docs.refs;.log.warn\"Docs name not found. Please add to docs.\";.log.info\"Available docs:\",.log.plainText .docs.refs;:(::)];\n    .util.stdout .docs.libs name};");

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
    .log.info"Making docs for: ",.util.strPath filePath;
    .mkdocs.chkFmt[filePath;content];
    title:2_first content;
    body:-1_3_content;
    body:.mkdocs.i.indent,/:(-3!'body),'";";
    body:@[body;-1+count body;{(-1_x),");"}];
    k:string .Q.id first` vs file;
    head:.mkdocs.mkhead[k;title];
    h head,body;};

/ Main
mkdocs:.mkdocs.mkdocs:{
    / Ensure full console size
    .term.full[];

    scriptPath:.util.getScriptPath{};
    dirname:.util.dirname scriptPath;
    docsPath:.q.Hsym docsPathStr:dirname,"/docs";
    if[not .util.exists docsPath;.log.info"Docs path not found: ",docsPathStr;:(::)];
    docsFile:key[docsPath]except`template.md;
    docsFile@:where docsFile like"*.md";
    if[not count docsFile;.log.info"No ",docsPathStr,"/*.md files found";:(::)];

    .mkdocs.saveFile:.q.Hsym docsQfileStr:docsPathStr,".q";
    @[hdel;.mkdocs.saveFile;{}];
    .log.info"Making docs q script: ",docsQfileStr;
    h:neg hopen .mkdocs.saveFile;

    .mkdocs.i.indent:.mkdocs.indent#"";
    h .mkdocs.header;
    .mkdocs.mkdoc[h;docsPath]'[docsFile];
    hclose abs h;
    -1 read0 .mkdocs.saveFile;
    };

// TODO: Add cmdline arguments q mkdocs.q docsPath saveFile
