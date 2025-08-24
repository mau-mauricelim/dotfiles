/############
/# Terminal #
/############

// INFO: https://github.com/CillianReilly/qtools/blob/master/q.q
clear:.term.clear:{1"\033[H\033[J";};
c:.term.setSize:{system"c ",$[.util.isStr x;;" "sv string 2#]x};
full:.term.full:{.term.setSize 20000};
.term.getSize:{$[.util.isWin[];(ssr[;"  ";" "]/)trim lower[raze system["mode con"]3 4]except":",.Q.a;first system"stty size"]};
resize:.term.resize:.term.setSize .term.getSize@;
paste:.term.paste:{get{$[(""~r:read0 0)and not sum 124-7h$x inter"{}";x;x,` sv enlist r]}/[""]};
