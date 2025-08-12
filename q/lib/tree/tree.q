/ List contents of directories/namespaces in a tree-like format
.tree.tree:{[path;maxDepth;dirFirst;showHidden]
    -1@1_string path;
    colors:@[value;".colors.enabled[]";0b];
    params:`path`prefix`maxDepth`dirFirst`showHidden`showColors!(path;"";maxDepth;dirFirst;showHidden;colors);
    cnt:1b,.tree.branch params;
    -1("";", "sv(string 0^(count each group cnt)10b),'" ",'("directories";"files");"");
    };
.tree.branch:{[params]
    entries:(),key path:params`path;
    if[not params`showHidden;entries@:where not entries like".*"]; / Hide hidden files
    if[params`dirFirst;entries@:raze group[.util.isFile peach .Q.dd[path]peach entries]01b];
    / Process each entry
    params[`maxDepth]-:1;
    raze{[params;entry;isLast]
        typeD:.util.isDir params[`path]:.Q.dd[params`path;entry];
        / The current branch would be in the following format:
        / "├── entry1"
        / "└── entryN"
        branch:$[.util.isWin[];
            $[isLast;"\300";"\303"],"\304\304";
            $[isLast;"└"   ;"├"   ],"──"     ]," ";
        / Print current entry (with colors)
        -1 params[`prefix],branch,
            $[params`showColors;{.colors.ansi[`bold,(`yellow`cyan x),`default],y,.colors.reset[]}typeD;]string entry;
        / The next level would be in the following format:
        / "├── " becomes "│   "
        / "└── " becomes "    "
        / e.g. level1: "[    │   ├── ]level1"     OR "[    │   └── ]level1"
        /      level2: "[    │   │   ]├── level2"    "[    │       ]└── level2"
        params[`prefix],:$[isLast;" ";.z.o like"w*";"\263";"│"],"   ";
        / Recursively process directories
        typeD,$[params[`maxDepth]&typeD;.tree.branch[params];()]
        }[params]'[entries;entries=last entries]
    };
/ If function is called with [], path defaults to current directory: `:.
// BUG: tree`hello
tree:{[path] .tree.tree[;10;1b;0b]$[(::)~path;`:.;path]};
treea:{[path].tree.tree[;10;1b;1b]$[(::)~path;`:.;path]};
