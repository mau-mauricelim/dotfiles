/##########
/# Schema #
/##########

/ @param force - boolean - 1b to enforce upper types
.schema.i.getTable:{[force;colNames;colTypes]
    colNames,:();
    colTypes,:();
    uppColTypes:where colTypes in .Q.A;
    colTypes:?[null colTypes;"*";colTypes];
    if[not force;colTypes:@[colTypes;uppColTypes;:;"*"]];
    / This returns an empty table with lower types
    schema:flip colNames!colTypes$\:();
    / This returns a table with a row with the correct types
    $[force;![;();0b;uppColNames!enlist,/:uppColNames:colNames uppColTypes]1#;]schema};
.schema.getTable:.schema.i.getTable 0b;
.schema.getTableForce:.schema.i.getTable 1b;
