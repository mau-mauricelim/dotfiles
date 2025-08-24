.Q.hex~"0123456789ABCDEF"
all`:filepath~'.q.Hsym each(`:filepath;`filepath;":filepath";"filepath")
(~). .Q.addr each .z.h,.z.ip
11111000b~.util.exists each(`;`.;`:.;`:lib;`:q.q;`varNoExists;`.nameSpaceNoExists;`:fileNoExists)
11110000b~.util.isDir each(`;`.;`:.;`:lib;`:q.q;`varNoExists;`.nameSpaceNoExists;`:fileNoExists)
00001000b~.util.isFile each(`;`.;`:.;`:lib;`:q.q;`varNoExists;`.nameSpaceNoExists;`:fileNoExists)
{not[count x]&exec"b x  "~t from meta x}.util.getTableSchema[`a`b`c`d`e;"bGx* "]
{(1~count x)&exec"bGx  "~t from meta x}.util.getTableSchemaForce[`a`b`c`d`e;"bGx* "]

/
// TODO: Add a test for .util.normPath and .util.normPathWin

if[not all{[f;out;inp] out~f inp}[`hb].'(
    (enlist"1023 B";1023);
    (("1 KB";"2.5 GB";"3.75 TB");(1024;1024*1024*1024*2.5;1024*1024*1024*1024*3.75)));
    '"`hb` function failed!"];

if[not all{[f;out;inp] out~f . inp}[`.util.humanReadableBytesInUnit].'(
    (enlist"0.9990234 KB";(1023;`kb));
    (("0.0009765625 MB";"2560 MB";"3932160 MB");((1024;1024*1024*1024*2.5;1024*1024*1024*1024*3.75);`MB)));
    '"`.util.humanReadableBytesInUnit` function failed!"];

if[not all{[f;out;inp] out~f . inp}[`.util.pad].'(
    (101000b;(6;101b));
    (000101b;(-6;101b));
    (1 2 3 0N 0N 0N;(6;1 2 3));
    (0N 0N 0N 1 2 3;(-6;1 2 3));
    (0 1 2 3 4 5;(6;til 10)));
    '"`.util.pad` function failed!"];

.util.randSeed[];
if[not{[n]
    res :n~count head r:til n2:n*2;
    res&:r~head[n2* 2]r;
    res&:r~head[n2*-2]r;
    res&:( n05#r)~head[ n05:n div 2]r;
    res&:(nn05#r)~head[nn05:neg n05]r;
    res&:(tail[ n05]r)~head[nn05]r;
    res&:(tail[nn05]r)~head[ n05]r;
    res}.head.n:rand 10000;
    '"`.util.head` or `.util.tail` function failed!"];

.test.passed 0b;
