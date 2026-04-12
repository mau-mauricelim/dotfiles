/###############
/# Color Names #
/###############

// INFO: https://meodai.github.io/color-names/
// INFO: https://github.com/meodai/color-names/blob/HEAD/src/colornames.csv
/ Load colornames.csv (large list of handpicked color names 🌈)
/ @global `.colors.dict
.colors.i.load:{
    if[.util.exists`.colors.dict;:(::)];
    scriptPath:.util.getScriptPath{};
    .colors.dict:`u#'flip("SS";enlist csv)0:.q.Hsym .util.dirname[scriptPath],"/data/colornames.csv";};

/ Lookup color based on key value pair
.colors.i.lookup:{[k;v;x]
    .colors.i.load[];
    $[null r:.colors.dict[k].colors.dict[v]?$[10h~type x;`$;]x;
        "#f0ck - ",string[count first .colors.dict]," colors and you can't find any!";
        string r]};

/ Lookup hex code from color name
/ @example - .colors.hexToColorName`Solarized
.colors.hexToColorName:.colors.i.lookup[`hex;`name];
/ Lookup color name from hex code
/ @example - .colors.colorNameToHex"#ffbbb4"
.colors.colorNameToHex:.colors.i.lookup[`name;`hex];
