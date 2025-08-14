// INFO: https://code.kx.com/q/basics/funsql/#the-solution
/ Better `parse` function
.parse.parse:{
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
        / For select statements within select statements
        x[1]:$[-11=type x 1;x 1;[idxs,:1;.z.s x 1]];
        x:@[x;ainds except idxs;string];
        strBrk:{y,(";" sv x),z};
        x[0],strBrk[1_x;"[";"]"]
        }[;ab];
    inner parse x};
/ Prints result to console and returns result
.q.Parse:{-1 res:.parse.parse x;res};
