if[not all{[f;funcForm;qSql] funcForm~f qSql}[`.parse.parse].'(
    ("?[t;enlist (=;`c1;enlist`c);0b;(enlist`c2)!enlist (*;2;`c2)]"                        ;"select c2:2*c2 from t where c1=`c");
    ("?[trade;enlist (>;`price;50);0b;(`sym`price`size)!`sym`price`size]"                  ;"select sym,price,size from trade where price>50");
    ("?[trade;enlist (>;140;(fby;(enlist;count;`i);`sym));0b;(enlist`x)!enlist (count;`i)]";"select count i from trade where 140>(count;i) fby sym");
    ("?[trade;((like;`sym;\"F*\");(not;(=;`sym;enlist`FD)));0b;()]"                        ;"select from trade where sym like \"F*\",not sym=`FD");
    ("![z;();0b;(enlist`tstamp)!enlist (reciprocal;`tstamp)]"                              ;"update tstamp:ltime tstamp from z");
    ("?[trade;();0b;();10 20]"                                                             ;"select[10 20] from trade");
    ("?[trade;();0b;();10 20;(idesc;`price)]"                                              ;"select[10 20;>price] from trade"));
    '"`Parse` function failed!"];

.test.passed 0b;
