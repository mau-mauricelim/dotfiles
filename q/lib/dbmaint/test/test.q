.lib.require`dbmaint / before
system"d .test" / before
n:1000; trade:([]time:2023.01.01+n?3D;sym:n?`3;price:n?10000f;size:n?10000) / before
trade:`sym`time xasc trade / before
g:trade group`date$trade`time / before
hdbDir:`:tmp/hdb / before
{[d;p;t].Q.dd[d;p,`trade`]set .Q.en[d;@[t;`sym;`p#]]}[hdbDir]'[key g;g] / before
met:([c:`date`time`sym`price`size]t:"dpsfj";f:`;a:```p``) / before
system"d ." / before
reload .test.hdbDir / before
.test.met~meta trade / true

addcol[`:data/taq;`trade;`$"!n^@li% n@><";0h] / fail
addcol[`:data/taq;`trade;`noo;0h] / run
castcol[`:data/taq;`trade;`size;`fail] / fail
castcol[`:data/taq;`trade;`size;`short] / run
copycol[`:data/taq;`trade;`size2;`size] / fail
copycol[`:data/taq;`trade;`size;`size2] / run

clearattrcol[`:data/taq;`trade;`sym] / run
deletecol[`:data/taq/;`trade;`size] / run

`:data/taq/2023.01.02/trade/ set .Q.en[`:data/taq] delete size from trade;

findcol[`:data/taq;`trade;`iz]

