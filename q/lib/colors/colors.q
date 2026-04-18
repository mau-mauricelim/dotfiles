/##########
/# Colors #
/##########

.lib.require`codec;

/ Convert 8-bit 256 color to RGB values
/ @param x - long - 256 color
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
    '.log.error"256 color (0-255)";
    };

.colors.i.isRgb:{(7h~type x)&3~count x};
.colors.i.rgbMod:{0^x mod 256};

/ Convert RGB values to hex code
/ @param rgb - long list of 3 rgb colors
/ @return - string of hex code
.colors.rgbToHex:{[rgb]
    if[not .colors.i.isRgb rgb;'.log.error"Not RGB values"];
    "#",raze flip .codec.decToHex .colors.i.rgbMod rgb};

.colors.i.hex:"#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]";
/ Symbol or string
.colors.i.isHex:{$[type[x]in -11 10h;x like .colors.i.hex;0b]};

/ Convert hex code to RGB values
/ @param hex - sym/string
/ @return - long list of 3 rgb colors
.colors.hexToRgb:{[hex]
    if[not .colors.i.isHex hex;'.log.error"Not hex code"];
    hex:ssr[.util.ensureStr hex;"#";""];
    .codec.hexToDec each 2 cut 6$hex};

/ Linearize sRGB channels
/ @param rgb - long list of 3 rgb colors
.colors.linear:{[rgb] rgb%:255;?[0.04045<rgb;((rgb+0.055)%1.055)xexp 2.4;rgb%12.92]};

/ Convert RGB to Oklab
// INFO: https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab
/ @param rgb - long list of 3 rgb colors
/ @return - float - (negative) ratio
.colors.rgbToOklab:{[rgb]
    lms:sum(0.4122214708 0.2119034982 0.0883024619;0.5363325363 0.6806995451 0.2817188376;0.0514459929 0.1073969566 0.6299787005)*.colors.linear rgb;
    lms:lms xexp reciprocal 3;
    lab:sum(0.2104542553 1.9779984951 0.0259040371;0.7936177850 -2.4285922050 0.7827717662;-0.0040720468 0.4505937099 -0.8086757660)*lms;
    @[lab;1 2;{x*1e-4<abs x}]};

// INFO: https://bottosson.github.io/posts/colorpicker/#intermission---a-new-lightness-estimate-for-oklab
/ @param x - number - Oklab lightness
.colors.correctLightness:{
    k3:(1+k1:0.206)%1+k2:0.03;
    0.5*t+sqrt(t*t:(k3*x)-k1)+4*k2*k3*x};

/ Check if color is dark
/ @param x - sym/string (hex code)
/            long (list of 3 rgb colors)
/ @param mode - sym - `256`rgb`hex according to x
/ @return - boolean - 1b if color is dark
/ @example - .colors.i.isDark["#8b4513";`hex]
.colors.i.isDark:{[x;mode]
    f:(.colors.256ToRgb;{x};.colors.hexToRgb;{'.log.error"mode"})`256`rgb`hex?mode;
    0.5>.colors.correctLightness first .colors.rgbToOklab f x};

// Compute opposite color
/ @param x - long - 256 color
/ @return - long - 15 (white)/0 (black)
.colors.opposite256:15*.colors.i.isDark[;`256]@;
/ @param x - long list of 3 rgb colors
/ @return - long list of 3 rgb colors - 255 255 255 (white)/0 0 0 (black)
.colors.oppositeRgb:3#255*.colors.i.isDark[;`rgb]@;
/ @param x - sym/string - hex code
/ @return - string - "#ffffff" (white)/"#000000" (black)
.colors.oppositeHex:"#",6#"0f".colors.i.isDark[;`hex]@;

.colors.i.find:{x?x inter y};
.colors.i.findColor:{[xg;base]
    if[.colors.i.isHex xg;xg:.colors.hexToRgb xg];
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
/ @param fg/bg - sym/string (color/styles/hex code)
/                long (list of 3 rgb colors)
/ @example - .colors.ansi[`bold`italic;`blue;`default]
/            .colors.ansi[`underline;190;`default]     / styles are stacked
/            .colors.ansi[`reset;"#77a1f9";48 48 48]
/            .colors.ansi[`reset;();()]                / reset all modes (styles and colors)
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
