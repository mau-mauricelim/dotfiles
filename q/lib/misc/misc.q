/########
/# Misc #
/########

/ CillianReilly
reflect:.util.reflect:{x,1_reverse x};
/ Composing using :: instead of @ also gives some performance:
pyramid:.util.pyramid:reflect reflect each{x&/:x:1+til x}::;

// INFO: https://code.kx.com/q/basics/handles/#read
read:.util.read:{
    -1"Reading from the console with read0 permits interactive input.";
     1"Please enter your input: ";read0 0};

/ Frecency of all chars
fcy:.util.charFrecency:desc count each group raze read0@;
/ Frecency of all special chars
fcys:.util.specialCharFrecency:desc .Q.sc#.util.charFrecency@;

// INFO: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#section-links
/ @param x - string
ghSecLink:.util.getGithubSectionLinks:{ssr[;" ";"-"]ssr[;"  ";" "]/[lower trim x]except .Q.sc except"-"};
