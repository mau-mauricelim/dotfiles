/##########
/# Browse #
/##########

.browse.cmd:"mwlsv"!({"open"};{"start \"\""};{$[.util.isWsl[];"cmd.exe /c start";"xdg-open"]})where 1 1 3;
/ Browse url or file - url has to start with http[s]://
browse:.browse.browse:{[url] .log.system .browse.cmd[first string .z.o][]," \"",url,"\""};

.browse.engine:"https://google.com/search?q=";
.browse.codeKx:"https://code.kx.com";
/ https://google.com/search?q=search query
query:.browse.query:{.browse.browse .browse.engine,x};
/ https://google.com/search?q=site:https://code.kx.com+search query
kdocs:.browse.kdocs:{.browse.browse .browse.engine,"site:",.browse.codeKx,"+",x};
/ https://code.kx.com/q?q=search query
qdocs:.browse.qdocs:{.browse.browse .browse.codeKx,"/q?q=",x};
