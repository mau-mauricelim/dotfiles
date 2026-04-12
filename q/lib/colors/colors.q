/##########
/# Colors #
/##########

.lib.require`codec;

/ Convert 8-bit 256 colors to RGB values
/ @param x - long - 256 colors
/ @return - long list of 3 rgb colors
.colors.256ToRgb:{
    if[x within 0 15;
        :$[any g:7 8=x;3#192 128 where g;
            ?[.codec.decToBinX[4][x]3 2 1;255 128 x<8;0]]];
    if[x within 16 231;
        x-:16;
        x:((div;mod;{y;x})@'x)@'36;
        x:(({y;x};div;mod)@'x)@'6;
        :0 95 135 175 215 255 x];
    if[x<256;:3#8+10*x-232];
    '.log.error"256 colors (0-255)";
    };

.colors.i.isRgb:{(7h~type x)&3~count x};
.colors.i.rgbMod:{0^x mod 256};

/ Convert RGB values to hex code
/ @param rgb - long list of 3 rgb colors
/ @return - string of hex code
.colors.rgbToHex:{[rgb]
    if[not .colors.i.isRgb rgb;'.log.error"Not RGB values"];
    "#",raze flip .codec.decToHex .colors.i.rgbMod rgb};

/ Convert hex code to RGB values
/ @param hex - sym/string
/ @return - long list of 3 rgb colors
.colors.hexToRgb:{[hex]
    $["#"~first hex:.util.ensureStr hex;hex _:0;];
    if[not all floor[hex]in .Q.hex;'.log.error"Not hex code"];
    .codec.hexToDec each 2 cut 6$hex};

.colors.i.find:{x?x inter y};
.colors.i.findColor:{[xg;base]
    // NOTE: ";38" and ";48" corresponds to the 16 color sequence and is interpreted by the terminal to set the fg and
    // bg color respectively. Wheras ";2" and ";5" sets the color format of RGB and 256 colors respectively.
    seq:{[xg;base;fmt] (base+8),fmt,.colors.i.rgbMod xg}[xg;base];
    / 4-bit 16 colors
    seq$[-11h~typ:type xg;:base+.colors.i.find[`black`red`green`yellow`blue`magenta`cyan`white``default;xg];
        / 8-bit 256 colors
        -7h~typ;5;
        / 24-bit RGB colors
        .colors.i.isRgb xg;2;
        :()]};

/ Get string of ANSI escape sequences for specified styles and colors
/ @param styles - sym (list) - styles can be stacked
/ @param fg - sym/long (list of 3 rgb colors)
/ @param bg - sym/long (list of 3 rgb colors)
/ @example - .colors.ansi[`bold`italic;`blue;`default]
/            .colors.ansi[`underline;190;`default] / styles are stacked
/            .colors.ansi[`reset;75;48 48 48]
/            .colors.ansi[`reset;();()]            / reset all modes (styles and colors)
.colors.ansi:{[styles;fg;bg]
    // NOTE: reset is to reset the previous modes on top of applying the current one
    modes:.colors.i.find[`reset`bold`dim`italic`underline`blink.slow`blink.fast`inverse`hidden`strikethrough;styles];
    modes,:.colors.i.findColor[fg;30];
    modes,:.colors.i.findColor[bg;40];
    "\033[",(";"sv string modes),"m"};

/ Wrap text with specified styles and colors then reset
/ @param text - string of text to wrap
/ @example - .colors.wrap[`bold`italic;`blue;`default;"Bold and italic blue text on default background"]
.colors.wrap:{[styles;fg;bg;text] .colors.ansi[styles;fg;bg],text,.colors.reset[]};

/ Reset all modes
/ @global `.colors.i.reset
.colors.reset:{@[get;`.colors.i.reset;{:.colors.i.reset:.colors.ansi[`reset;();()]}]};

/ Check if colors is enabled else has terminal colors capability
.colors.enabled:{@[get;`.colors.i.enabled;.colors.capable]};

/ Explicit function to enable colors regardless of terminal colors capability
/ @global `.colors.i.enabled
.colors.on:{.colors.i.enabled:1b};
.colors.off:{.colors.i.enabled:0b};

/ Check terminal colors capability
/ @global `.colors.i.capable
.colors.capable:{@[get;`.colors.i.capable;{:.colors.i.capable:.util.isWin[]|"xterm-256color"~getenv`TERM}]};
