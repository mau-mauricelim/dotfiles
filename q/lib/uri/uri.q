/#######
/# URI #
/#######

.uri.chr:.Q.an,.Q.sc," ";
/ URI-encoding has reserved and unreserved characters set
/ But in this encoding map all characters are used
.uri.map:"%",'.Q.hex 16 vs'.uri.chr!`int$.uri.chr;
.uri.enc:{raze((d!d:distinct x),y)x}[;.uri.map];
.uri.dec:{1_(value[y]!key y)"%",'"%"vs x}[;.uri.map];
