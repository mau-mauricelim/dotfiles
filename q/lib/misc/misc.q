/#################
/# Miscellaneous #
/#################

/ CillianReilly
reflect:.shape.reflect:{x,1_reverse x};
/ Composing using :: instead of @ also gives some performance:
pyramid:.shape.pyramid:reflect reflect each{x&/:x:1+til x}::;

// INFO: https://code.kx.com/q/basics/handles/#read
read:.read.read:{
    -1"Reading from the console with read0 permits interactive input.";
     1"Please enter your input: ";read0 0};

/ Frecency of all chars
fcy:.fcy.charFrecency:desc count each group raze read0@;
/ Frecency of all special chars
fcys:.fcy.specialCharFrecency:desc .Q.sc#.fcy.charFrecency@;

// INFO: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#section-links
/ @param x - string
ghSecLink:.gh.sectionLink:{ssr[;" ";"-"]ssr[;"  ";" "]/[floor trim x]except .Q.sc except"-"};

/ Function to print a pacman progress bar
/ @param pct - boolean - print status as percentage
/ @param current - number - current progress
/ @param total - number - total progress
/ @param bar - number - length of bar
/ @return - string
/ @example - .pacman.i.progress[0b;10;30;30]
.pacman.i.progress:{[pct;current;total;length]
    (current;total;length):floor 0|current,total,length;
    ratio:0^current%total|:current;
    pos:floor ratio*length|:1;
    bar:" ",@[length#"";2+3*til length div 3;:;"o"];
    bar:@[bar;pos;:;"cC""o"=bar pos+1];
    bar:@[bar;til pos;:;"-"];
    bar:@[bar;0;:;"["],"]";
    status:$[pct;(-4$string floor ratio*100),"%";" ","/"sv(neg count string total)$'string current,total];
    bar,status};

/ @example - .pacman.progress[10;60;50]
.pacman.progress:.pacman.i.progress 1b;
