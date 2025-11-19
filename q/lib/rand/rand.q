/#########################
/# Random Data Generator #
/#########################

// INFO: https://github.com/BuaBook/kdb-common/blob/master/src/rand.q
.rand.typeNulls:-1_.Q.t!rand each("*"^.Q.t)$\:();
/ Sensible default values for random data generation
.rand.typeDefaults:.rand.typeNulls,("hijefcs"!(256h;10000i;1000000j;100e;1000f;" ";`4)),{x!x$\:"p"$.z.d}"pmdznuvt";
.rand.maxListCount:5;

/ @param colNames - sym (list)
/ @param typeLetters - string (list)
/ @param n - number of rows
/ @example - .rand.table[`date`sym`price;"dsE";3]
.rand.table:{[colNames;typeLetters;n]
    colNames,:();
    typeLetters,:();
    if[not all(lowLetters:lower typeLetters)in .Q.t;'.log.error"Column type letters allowed: ",.Q.s1 distinct .Q.t];
    defaults:{[n;letter;lowLetter]
        $[letter in .Q.A;(1+n?.rand.maxListCount);n]?\:.rand.typeDefaults lowLetter
        }[0|n]'[typeLetters;lowLetters];
    flip colNames!defaults};

/ @example - .rand.schema[`date`sym`price;"dse"]
.rand.schema:.rand.table[;;0];
/ @example - .rand.schemaForce[`date`sym`price;"dsE"]
.rand.schemaForce:{[colNames;typeLetters]
    colNames,:();
    typeLetters,:();
    schema:.rand.table[colNames;typeLetters;force:any uppLetters:typeLetters in .Q.A];
    if[force;schema:flip@[schema@-1;colNames where uppLetters|null typeLetters;enlist]];
    schema};

/ Set .rand.typeName functions to generate a random value for the type name
/ @global `.rand.boolean`.rand.guid`.rand.byte`.rand.short`.rand.int`.rand.long`.rand.real`.rand.float`.rand.char`.rand.symbol`.rand.timestamp`.rand.month`.rand.date`.rand.datetime`.rand.timespan`.rand.minute`.rand.second`.rand.time
{name:`$$["c"~x;"char";ssr/[.Q.s1 x$();("`";"$()");("";"")]];
    .rand[name]:{rand y}[;.rand.typeDefaults x];
    }each distinct .Q.t except" ";
