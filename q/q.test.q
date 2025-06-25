if[not all{[f;funcForm;qSql] funcForm~f qSql}[`Parse].'(
    ("?[t;enlist (=;`c1;enlist`c);0b;(enlist`c2)!enlist (*;2;`c2)]"                        ;"select c2:2*c2 from t where c1=`c");
    ("?[trade;enlist (>;`price;50);0b;(`sym`price`size)!`sym`price`size]"                  ;"select sym,price,size from trade where price>50");
    ("?[trade;enlist (>;140;(fby;(enlist;count;`i);`sym));0b;(enlist`x)!enlist (count;`i)]";"select count i from trade where 140>(count;i) fby sym");
    ("?[trade;((like;`sym;\"F*\");(not;(=;`sym;enlist`FD)));0b;()]"                        ;"select from trade where sym like \"F*\",not sym=`FD");
    ("![z;();0b;(enlist`tstamp)!enlist (reciprocal;`tstamp)]"                              ;"update tstamp:ltime tstamp from z");
    ("?[trade;();0b;();10 20]"                                                             ;"select[10 20] from trade");
    ("?[trade;();0b;();10 20;(idesc;`price)]"                                              ;"select[10 20;>price] from trade"));
    '"`Parse` function failed!"];

if[not all{[f;out;inp] out~f inp}[`hb].'(
    (enlist"1023 B";1023);
    (("1 KB";"2.5 GB";"3.75 TB");(1024;1024*1024*1024*2.5;1024*1024*1024*1024*3.75)));
    '"`hb` function failed!"];

if[not all{[f;out;inp] out~f . inp}[`hbu].'(
    (enlist"0.9990234 KB";(1023;`kb));
    (("0.0009765625 MB";"2560 MB";"3932160 MB");((1024;1024*1024*1024*2.5;1024*1024*1024*1024*3.75);`MB)));
    '"`hbu` function failed!"];

if[not all{[f;out;inp] out~f . inp}[`pad].'(
    (101000b;(6;101b));
    (000101b;(-6;101b));
    (1 2 3 0N 0N 0N;(6;1 2 3));
    (0N 0N 0N 1 2 3;(-6;1 2 3));
    (0 1 2 3 4 5;(6;til 10)));
    '"`pad` function failed!"];

if[not all{[f;numStrs;numStr] numStr~f numStrs}[`bprd].'(
    (("81954661854927019218817245427856413378214280585286";"90009523959766478446992542587997719108831051001763");"7376700099845613400514947747291243436753821908525476800326597799858651163116984478725362292257859218");
    (("900095239597664784469925425879977";"191088310510017634348468283416442";"272057567021810733682389011969784");"46793269982246273975632144126564455775304399950377492185067815725449797049384188043481655670503856");
    (("819546.6185";"817.2454278";"4.927019218";"564133.7821";"0.280585286");"522344972019834.40678406591550971939310992632644"));
    '"`bprd` function failed!"];

if[not all(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97~primes 100;
    2 2 2 2 3 5~primeFzn 240;
    2 3 5~primeFac 240;
    1 2 4 7 8 11 13 14~coPrime 15;
    12 720~(gcd;lcm)@\:48 180 240);
    '"Prime factorization functions failed!"];

if[not all(0000000000000000000000000000000000000000000000000000000000010100b~`bi 20;
    20 20~`ib@'(10100b;1 0 1 0 0);
    512~`bls[256;1];
    128~`brs[256;1];
    127~`bor 123 45 6;
    80~`bxor 123 45 6);
    '"Bitwise operation functions failed!"];

if[not .uri.chr~.uri.dec .uri.enc .uri.chr;'"URI encoding functions failed!"];

exit 0*-1"All tests passed!";
