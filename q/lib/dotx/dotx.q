/######
/# .Q #
/######

.Q.hex:.Q.n,6#.Q.a;
/ Special characters on the keyboard
.Q.sc:"~`!@#$%^&*()_-+={[}]|\\:;\"'<,>.?/";
/ Datatypes
.Q.dtype:([name:`list`boolean`guid`byte`short`int`long`real`float`char`symbol`timestamp`month`date`datetime`timespan`minute`second`time]
    n:til[20]_3; c:"*bgxhijefcspmdznuvt"; sz:0N 1 16 1 2 4 8 4 8 1 0N 8 4 4 8 8 4 4 4);
/ .Q.w in human-readable bytes
.Q.wh:{`$.util.humanBytes .Q.w[]};
/ Decodes (and pad to length of multiple 4) base 64 data
/ @example - `char$.Q.atobp"SGVsbG8sIFdvcmxkIQ"
.Q.atobp:{
    / Pad to length of multiple 4
    x:"="^.q.roundup[4;count x]$x:(x?"=")#x;
    `byte$(neg sum"="=x)_raze flip 256 vs 64 sv'0N 4#.Q.b6?x};

/######
/# .q #
/######

// INFO: https://code.kx.com/phrases/
// NOTE: Syntax `x function y` can be used if the function is defined in the root namespace

.q.xor:<>;
.q.rename:xcol;
.q.reorder:xcols;

/ Round y to nearest multiple of x
/ @example - 4 roundm 18
.q.round:{x*floor 0.5+y%x};
.q.roundup:{x*ceiling y%x};

/ Remove leading or trailing X from a list
/ @example - "-" trimX "--- Hello, --- World! ---"
.q.trimX:{.q.ltrimX[x].q.rtrimX[x]y};
/ @example - "-" ltrimX "--- Hello, --- World! ---"
.q.ltrimX:{((x=y)?0b)_y};
/ @example - "-" rtrimX "--- Hello, --- World! ---"
.q.rtrimX:{(neg(x=reverse y)?0b)_y};

/######
/# .z #
/######

.z.hf:.Q.host .z.a;
.z.ip:`$"."sv string 256h vs .z.a;
