/################
/# Fuzzy finder #
/################

/ Fuzzy search namespace objects - case and order insensitive
/ @global `.fzf.cache - dict cache
/ @param pat - sym (list)
// NOTE: add a null sym to regenerate cache
/ @example - .fzf.fzfObject`search`pattern
/ @return - sym list
fzf:.fzf.fzfObject:{[pat]
    if[(any null pat)|not .util.exists`.fzf.cache;
        obj@:where -11h=type each obj:1_.util.recurseDir`;
        obj,:last each` vs'1_.util.recurseDir`.;
        .fzf.cache:obj!lower string .Q.id peach obj];
    pat:{"*",x,"*"}each lower string .util.exceptNulls(),pat;
    where{all y like/:x}[pat]peach .fzf.cache};
/ @return - table of objects and its values
fzfv:.fzf.fzfObjectVal:{[pat]([]obj;val:get each obj:.fzf.fzfObject pat)};
/ @return - table of objects and its approximate memory usage
fzfm:.fzf.fzfObjectMem:{[pat] delete val from update human:hb peach size from update size:{-22!x}peach val from .fzf.fzfObjectVal pat};
/ Get the object name of the value
/ @example - q)).fzf.getObjectName .z.s
/            q)whoami whoami
whoami:.fzf.getObjectName:{t:.fzf.fzfObjectVal`;exec obj from t where val~'x};
