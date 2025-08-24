/##########
/# Colors #
/##########

/ Select Graphic Rendition
.colors.sgr:{[style;fg;bg]
    s:`reset`bold`faint`italic`underline!til 5;
    c:`default`black`red`green`yellow`blue`magenta`cyan`white!39 30 31 32 33 34 35 36 37;
    (s;c;c+10)@'style,fg,bg}.;
.colors.ansi:{[style;fg;bg]
    n:";"sv string .colors.sgr style,fg,bg;
    csi:"\033[";
    csi,n,"m"}.;
.colors.reset:{@[get;`.colors.i.reset;{:.colors.i.reset:.colors.ansi`reset``}]};
.colors.enabled:{@[get;`.colors.i.enabled;{:.util.isWin[]|"xterm-256color"~getenv`TERM}]};
