/########
/# Misc #
/########

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
