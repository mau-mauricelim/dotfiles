/ Adapted from https://code.kx.com/q/basics/funsql/#the-solution
/ Better `parse` function
Parse:{
    system"c 30 200";

    / Replace k representation with equivalent q keyword
    funcK:{
        kreplace:{[x] $[`=qval:.q?x;x;"~~",string[qval],"~~"]};
        $[0=t:type x;.z.s each x;t<100h;x;kreplace x]
        };
    / Replace eg ,`FD`ABC`DEF with "enlist`FD`ABC`DEF"
    funcEn:{
        ereplace:{"~~enlist",(.Q.s1 first x),"~~"};
        ereptest:{(1=count x) and ((0=type x) and 11=type first x) or 11=type x};
        $[ereptest x;ereplace x;0=type x;.z.s each x;x]
        };
    tidy:{ssr/[;("\"~~";"~~\"");("";"")] $[","=first x;1_x;x]};
    basic:tidy .Q.s1 funcK funcEn ::;

    / Where clause needs to be a list of Where clauses,
    / so if only one Where clause, need to enlist.
    stringify:{[x;basic] $[(0=type x) and 1=count x;"enlist ";""],basic x}[;basic];
    / If a dictionary, apply to both keys and values
    ab:{[x;stringify]
        addbraks:{"(",x,")"};
        $[(0=count x) or -1=type x; .Q.s1 x;
            99=type x; (addbraks stringify key x ),"!",stringify value x;
            stringify x]
        }[;stringify];

    inner:{[x;ab]
        idxs:2 3 4 5 6 inter ainds:til count x;
        x:@[x;idxs;'[ab;eval]];
        if[6 in idxs;x[6]:ssr/[;("hopen";"hclose");("iasc";"idesc")] x[6]];
        //for select statements within select statements
        x[1]:$[-11=type x 1;x 1;[idxs,:1;.z.s x 1]];
        x:@[x;ainds except idxs;string];
        strBrk:{y,(";" sv x),z};
        x[0],strBrk[1_x;"[";"]"]
        }[;ab];

    inner parse x
    };

/ Simple unit test
if[not all({[f;funcForm;qSql] funcForm~f qSql}[Parse]).'(
    ("?[t;enlist (=;`c1;enlist`c);0b;(enlist`c2)!enlist (*;2;`c2)]"                        ;"select c2:2*c2 from t where c1=`c");
    ("?[trade;enlist (>;`price;50);0b;(`sym`price`size)!`sym`price`size]"                  ;"select sym,price,size from trade where price>50");
    ("?[trade;enlist (>;140;(fby;(enlist;count;`i);`sym));0b;(enlist`x)!enlist (count;`i)]";"select count i from trade where 140>(count;i) fby sym");
    ("?[trade;((like;`sym;\"F*\");(not;(=;`sym;enlist`FD)));0b;()]"                        ;"select from trade where sym like \"F*\",not sym=`FD");
    ("![z;();0b;(enlist`tstamp)!enlist (reciprocal;`tstamp)]"                              ;"update tstamp:ltime tstamp from z");
    ("?[trade;();0b;();10 20]"                                                             ;"select[10 20] from trade");
    ("?[trade;();0b;();10 20;(idesc;`price)]"                                              ;"select[10 20;>price] from trade"));'"`Parse` function failed!"];

/ kdb+ paster
/ https://learninghub.kx.com/forums/topic/kdb-paster/
/ https://github.com/CillianReilly/qtools/blob/master/q.q
paste:{value{$[(""~r:read0 0)and not sum 124-7h$x inter"{}";x;x,` sv enlist r]}/[""]};
clear:{1"\033[H\033[J";};
resize:{system"c ",first system"stty size"};

