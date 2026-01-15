/##################################
/# Make rlwrap auto complete file #
/##################################

.lib.require`fzf;

/ @param obj - sym (list) - variables, functions, namespaces, etc. to include in the auto complete file
/ @param ign - sym (list) - ignore list
/ @return - string list
.mkcomp.list:{[obj;ign]
    obj:asc distinct obj,.fzf.recurseNs obj;
    obj:obj except``.,ign,:();
    obj@:where not max obj like/:string[ign],\:".*";
    obj:ssr[;"..";""]each string obj;
    obj where not obj like"*."};

.mkcomp.listAll:{.mkcomp.list[``.;`.mkcomp]};

.mkcomp.write:{(x:.q.Hsym x)0:y;.log.info"Rlwrap auto complete file written to: ",.util.strPath x};

/ If file is ran as a script
if[.util.isStartupFile{};
    $[1>count .Q.x;
        .log.info each("Usage: q ",f," SAVEFILE";"Example: q ",(f:string .z.f)," rlwrap_completion");
        .mkcomp.write[.Q.x 0;.mkcomp.listAll[]]];
    exit 0];
