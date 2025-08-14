// INFO: Inspired by https://github.com/KxSystems/help
/ Create docs q script from ./docs/*.md files

.mkdocs.indent:4;
.mkdocs.header:(
    "// NOTE: This q script was generated using mkdocs.q";
    "";
    "/########";
    "/# Docs #";
    "/########";
    "";
    ".docs.ref:()!()");
.mkdocs.footer:(
    "/ The global functions print the docs to the console";
    "{x set{x;.util.stdout y;}[;trim y]}.'flip(key;value)@\\:.docs.docs _`;");

.mkdocs.mkhead:{[k;title]
    ("";
    ".docs.ref[`",k,"]:",(-3!title),";"
    ".docs.docs.",k,":(")};
.mkdocs.mkdoc:{[path;file]
    content:read0 .Q.dd[path;file];
    // TODO: Maybe update logic?
    title:2_first content;
    body:-1_3_content;
    // BUG? Need to update logic if single line?
    body:.mkdocs.i.indent,/:(-3!body),'";";
    body:@[body;-1+count body;{(-1_x),");"}];

    k:string .Q.id first` vs file;
    head:.mkdocs.mkhead[k;title];
    .mkdocs.docsQfileHandle head,body;
    };

/ Main
.mkdocs.mkdocs:{
    / Ensure full console size
    .term.full[];

    scriptPath:.util.getScriptPath{};
    dirname:.util.dirname scriptPath;
    docsPath:.q.Hsym docsPathStr:dirname,"/docs";
    docsFile:key docsPath;
    docsFile@:where docsFile like"*.md";
    if[not count docsFile;.log.info"No ",docsPathStr,"/*.md files found";:(::)];

    docsQfile:.q.Hsym docsPathStr,".q";
    @[hdel;docsQfile;{}];
    .mkdocs.docsQfileHandle:neg hopen docsQfile;

    .mkdocs.i.indent:.mkdocs.indent#"";
    .mkdocs.docsQfileHandle .mkdocs.header;
    .mkdocs.mkdoc[docsPath]'[docsFile];
    hclose abs .mkdocs.docsQfileHandle;
    };

// TODO: Add a template format
/        Add a README
/        Add cmdline arguments for script name and output dir
/        Add code comments for above
/        Add logging
