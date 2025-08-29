/################
/# Fuzzy finder #
/################

/ Fuzzy search namespace objects
/ Smart-case: if pattern is all lower case, search is case insensitive
/ @global `.fzf.cache - dict cache
/ @param pat - sym (list)
// NOTE: add a null sym to regenerate cache
/ @example - .fzf.fzfObject`search`pattern
/ @return - sym list
fzf:.fzf.fzfObject:{[pat]
    if[(any null pat)|not .util.exists`.fzf.cache;
        obj:raze .util.recurseDir each``.;
        obj@:where{@[.util.exists;x;0b]}each obj;
        obj@:where -11h=type each obj;
        obj@:where{@[{get x;1b};x;0b]}each obj;
        .fzf.cache:obj!string .Q.id each obj];
    pat:string .Q.id each .util.exceptNulls(),pat;
    allLower:all raze[pat] in .Q.a;
    pat:{"*",x,"*"}each pat;
    where{all y like/:x}[pat]each$[allLower;lower;].fzf.cache};
/ @return - table of objects and its values
fzfv:.fzf.fzfObjectVal:{[pat]([]obj;val:get each obj:.fzf.fzfObject pat)};
/ @return - table of objects and its approximate memory usage
fzfm:.fzf.fzfObjectMem:{[pat] delete val from update human:hb peach size from update size:{-22!x}peach val from .fzf.fzfObjectVal pat};
/ Get the object name of the value
/ @example - q)).fzf.getObjectName .z.s
/            q)whoami whoami
whoami:.fzf.getObjectName:{t:.fzf.fzfObjectVal`;exec obj from t where val~'x};
