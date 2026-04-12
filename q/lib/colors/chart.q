/###############
/# Color Chart #
/###############

.colors.i.print8:{[fg;x] raze each{.colors.wrap[();;;(-4$string x),1#""].$[y;;reverse](x;())}[;fg]each'x};
.colors.i.chart8:{[fg]
    print:.colors.i.print8 fg;
    italic:.colors.wrap[`italic;();()];
    -1@'(.colors.wrap[`bold`underline;();();$[fg;"Fore";"Back"],"ground Colors"];"");
    -1@'(italic"Base 16"                ;"";print 8 cut til 16      ;"");
    -1@'(italic"6x6x6 RDB Color Cube"   ;"";print 16+(6*3)cut til 6*6*6;"");
    -1@'(italic"24-color Grayscale Ramp";"";print 232+12 cut til 24 ;"");
    };

/ Print a color chart of 8-bit 256 colors
.colors.chart8:{.colors.i.chart8 each 10b;};

/ Prints a 24-bit RGB color chart as a horizontal grid
/ Each row holds one fixed red value across all green/blue combinations
/ @param step - long - gap between color samples e.g. 30 (smaller = more colors)
/ @param char - string - character used to fill each color cell e.g. "."
/ @example - .colors.h.chart24[30;"."]
.colors.h.chart24:{[step;char] -1@'raze each(n*n)cut
    .colors.wrap[();();;char]each c cross c cross c:step*til n:256 div step;};

/ Same as .colors.h.chart24 but duplicate rows to compensate cursor width being smaller
/ @param ratio - how many times taller a character is than wide e.g. 2
/ @example - .colors.chart24[2;60;" "] / ratio 2 looks more like a square
/            .colors.chart24[1;80;"x"] / ratio 1 is an actual square
.colors.chart24:{[ratio;step;char] -1@'raze each'(floor n%ratio)#'enlist each(n*n)cut
    .colors.wrap[();();;char]each c cross c cross c:step*til n:256 div step;};
