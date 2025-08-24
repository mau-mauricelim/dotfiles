/#########
/# Bytes #
/#########

/ Human-readable bytes in specified unit
hbu:.util.humanReadableBytesInUnit:{[bytes;unit]
    units:`$b,"KMGTPEZY",'b:"B";
    if[specified:not(::)~unit;
        if[null units offset:units?unit:upper unit;'"Unit not found in: ",-3!units]];
    power:0^floor(binary:1024)xlog bytes,:();
    size:bytes%binary xexp power;
    if[specified;size*:binary xexp power-offset];
    $[specified;,\:[;string unit];,'[;string units power]]string[size],'" "};
hb:.util.humanReadableBytes:.util.humanReadableBytesInUnit[;(::)];
