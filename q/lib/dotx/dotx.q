/######
/# .Q #
/######

.Q.hex:.Q.n,6#.Q.A;
/ Special characters on the keyboard
.Q.sc:"~`!@#$%^&*()_-+={[}]|\\:;\"'<,>.?/";
/ Datatypes
.Q.dtype:([name:`list`boolean`guid`byte`short`int`long`real`float`char`symbol`timestamp`month`date`datetime`timespan`minute`second`time]
    n:til[20]_3; c:"*bgxhijefcspmdznuvt"; sz:0N 1 16 1 2 4 8 4 8 1 0N 8 4 4 8 8 4 4 4);

/######
/# .q #
/######

.q.xor:<>;
.q.rename:xcol;
.q.reorder:xcols;

/######
/# .z #
/######

.z.hf:.Q.host .z.a;
.z.ip:`$"."sv string 256h vs .z.a;
