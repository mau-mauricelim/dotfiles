/#########
/# Cache #
/#########

// INFO: https://github.com/adotsch/aoc/blob/master/2023/cached.q
/ General function to cache a function for recursive calls
/ @example - .cache.cacheFn[`f;{[x;y] y*x xexp til 1000000}]
cacheFn:.cache.cacheFn:{[fnName;fn]
    if[-11h<>type fnName;'symbol];
    / Projection ("placeholder") for the input params - e.g. enlist[;][2;3]
    projection:({};{enlist x};(;);(;;);(;;;);(;;;;);(;;;;;);(;;;;;;);(;;;;;;;)).util.valence fn;
    / General cached function
    cachedFn:{[cacheDict;fn;params]
        / Retrieve result from cache with serialized (-8!) input params
        if[not(::)~res:cacheDict byte:-8!params;:res];
        / Compute the result and add it to the cache
        @[cacheDict;byte;:;res:fn . params];
        res}[.cache.cacheInit fnName;fn];
    // INFO: https://code.kx.com/q/ref/compose/
    / (Re)defines original function with the composition of the cached function and projection
    fnName set(')[cachedFn;projection]
    };
/ (Re-)init cache (dict) for the function name
cacheInit:.cache.cacheInit:{[fnName] .Q.dd[`.cache.cache;fnName]set(`g#enlist 0#0x0)!enlist{value}};

// INFO: https://code.kx.com/q/ref/value/#lambda
/ Valence (rank) of a function
valence:.util.valence:{if[100h<>type x;'function]; count value[x]1};
