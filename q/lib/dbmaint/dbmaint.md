# 🛠️ dbmaint _(Database maintenance)_
Utility functions [dbmaint.q](dbmaint.q) for **kdb+ partitioned database tables maintenance**

**NOT FOR**:
- Splayed tables which are not partitioned
- Tables stored as single files
- In-memory tables

> [!NOTE]
> Some functions noted below may not support nested columns or supports only certain nested types

> [!TIP]
> Changes made to an existing database needs to be reloaded (`\l .`) for it to take effect
> - Additionally, table schemas needs to be modified on a tick database

> [!CAUTION]
> Test the effect of these utility functions on a [sample database](https://github.com/KxSystems/kdb-taq/tree/master) first before attempting it in production

## Usage examples
### Sample database
Generate sample database:
```q
n:1000;
trade:`sym`time xasc([]sym:n?`3;time:2023.01.01+n?3D;price:n?10000f;size:n?10000);
g:trade group`date$trade`time;
hdbDir:`:tmp/hdb;
{[d;p;t].Q.dd[d;p,`trade`]set .Q.en[d;@[t;`sym;`p#]]}[hdbDir]'[key g;g];
```
#### Changes:
*Directory:*
```sh
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.02
│   └── trade
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.03
│   └── trade
│       ├── price
│       ├── size
│       ├── sym
│       └── time
└── sym
```
*meta:*
```q
c    | t f a
-----| -----
date | d
sym  | s   p
time | p
price| f
size | j
```

### `addCol`
Add a new column (`colName`)
with the default value (`defaultVal`)
to each row of the existing table (`tabName`)
on the hdb directory (`hdbDir`)
```q
/ @usage
addCol[hdbDir;tabName;colName;defaultVal]
/ @example
addCol[`:tmp/hdb;`trade;`noo;0h]
```
#### Changes:
*Directory:*
```sh
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.02
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.03
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── sym
│       └── time
└── sym
```
*meta:*
```q
c    | t f a
-----| -----
date | d
sym  | s   p
time | p
price| f
size | j
noo  | h
```

### `castCol`
Cast the values of the existing column (`colName`)
with the new type (`newType`)
to the existing table (`tabName`)
on the hdb directory (`hdbDir`)
- `newType` can be specified in short or long form, e.g. `"f"` or `` `float`` for a cast to float
> [!NOTE]
> To cast nested type columns, use `funcCol` instead, e.g. cast a nested character column to symbol
```q
/ @usage
castCol[hdbDir;tabName;colName;newType]
/ @example
castCol[`:tmp/hdb;`trade;`size;`short]
```
#### Changes:
*meta:*
```q
c    | t f a
-----| -----
date | d
sym  | s   p
time | p
price| f
size | h
noo  | h
```

### `clearAttrCol`
Clear the attributes of the existing column (`colName`)
from the existing table (`tabName`)
on the hdb directory (`hdbDir`)
```q
/ @usage
clearAttrCol[hdbDir;tabName;colName]
/ @example
clearAttrCol[`:tmp/hdb;`trade;`sym]
```
#### Changes:
*meta:*
```q
c    | t f a
-----| -----
date | d
sym  | s
time | p
price| f
size | h
noo  | h
```

### `copyCol`
Copy the values of the existing column (`oldName`)
to the new column (`newName`)
of the existing table (`tabName`)
on the hdb directory (`hdbDir`)
> [!WARNING]
> TODO: Does not support nested columns currently
```q
/ @usage
copyCol[hdbDir;tabName;oldName;newName]
/ @example
copyCol[`:tmp/hdb;`trade;`size;`size2]
```
#### Changes:
*Directory:*
```sh
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── size2
│       ├── sym
│       └── time
├── 2023.01.02
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── size2
│       ├── sym
│       └── time
├── 2023.01.03
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── size2
│       ├── sym
│       └── time
└── sym
```
*meta:*
```q
c    | t f a
-----| -----
date | d
sym  | s
time | p
price| f
size | h
noo  | h
size2| h
```

### `deleteCol`
Delete the existing column (`colName`)
from the existing table (`tabName`)
on the hdb directory (`hdbDir`)
> [!WARNING]
> TODO: Does not support nested columns currently
> - Manually delete the `colName#` files for nested columns (the files containing the actual values)
```q
/ @usage
deleteCol[hdbDir;tabName;colName]
/ @example
deleteCol[`:tmp/hdb;`trade;`size]
```
#### Changes:
*Directory:*
```sh
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── noo
│       ├── price
│       ├── size2
│       ├── sym
│       └── time
├── 2023.01.02
│   └── trade
│       ├── noo
│       ├── price
│       ├── size2
│       ├── sym
│       └── time
├── 2023.01.03
│   └── trade
│       ├── noo
│       ├── price
│       ├── size2
│       ├── sym
│       └── time
└── sym
```
*meta:*
```q
c    | t f a
-----| -----
date | d
sym  | s
time | p
price| f
noo  | h
size2| h
```

### Broken HDB
> [!TIP]
> - `findCol` can be used to inspect a broken HDB
> - `fixTab` can be used to fix a broken HDB

Simulate broken HDB:
```q
.dbm.rename1Col[`:tmp/hdb/2023.01.02/trade;`size2;`size]
```
#### Changes:
*Directory:*
```sh
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── noo
│       ├── price
│       ├── size2
│       ├── sym
│       └── time
├── 2023.01.02
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.03
│   └── trade
│       ├── noo
│       ├── price
│       ├── size2
│       ├── sym
│       └── time
└── sym
```

### `findCol`
Find and print the existing column (`colName`) with its type in each partition directory
of the existing table (`tabName`)
on the hdb directory (`hdbDir`)
> [!TIP]
> Prints warning message if the column is not found in any partition directory
```q
/ @usage
findCol[hdbDir;tabName;colName]
/ @example
findCol[`:tmp/hdb;`trade;`size2]
```
***Output:***
```q
2025.09.20D08:44:33.715587773 [INFO]: Found column: [size2] of type [5h "h"] in [`:tmp/hdb/2023.01.01/trade]
2025.09.20D08:44:33.715682103 [WARN]: Missing column: [size2] in [`:tmp/hdb/2023.01.02/trade]
2025.09.20D08:44:33.716709532 [INFO]: Found column: [size2] of type [5h "h"] in [`:tmp/hdb/2023.01.03/trade]
```

### `fixTab`
Fix the existing table (`tabName`)
based on a reference good parition (`goodPartition`)
on the hdb directory (`hdbDir`)
> [!NOTE]
> Add missing, delete extra and reorder columns on all partitions of existing table
> - Does not add missing table to partitions, use `.Q.chk` for that
```q
/ @usage
fixTab[hdbDir;tabName;goodPartition]
/ @example
fixTab[`:tmp/hdb;`trade;2023.01.01]
```
***Output:***
```q
2025.09.20D08:52:21.002862728 [INFO]: Fixing table: [`:tmp/hdb/2023.01.02/trade]
2025.09.20D08:52:21.003922109 [INFO]: Adding column: [size2] of type: [5h "h"] to: [`:tmp/hdb/2023.01.02/trade]
2025.09.20D08:52:21.004681858 [INFO]: Deleting column: [size] in: [`:tmp/hdb/2023.01.02/trade]
2025.09.20D08:52:21.004968595 [INFO]: Reordering columns in [`:tmp/hdb/2023.01.02/trade]
```
#### Changes:
*Directory:*
```sh
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── noo
│       ├── price
│       ├── size2
│       ├── sym
│       └── time
├── 2023.01.02
│   └── trade
│       ├── noo
│       ├── price
│       ├── size2
│       ├── sym
│       └── time
├── 2023.01.03
│   └── trade
│       ├── noo
│       ├── price
│       ├── size2
│       ├── sym
│       └── time
└── sym
```

### `funcCol`
Apply the function (`func`)
to the values of the existing column (`colName`)
of the existing table (`tabName`)
on the hdb directory (`hdbDir`)
```q
/ @usage
funcCol[hdbDir;tabName;colName;func]
/ @example
funcCol[`:tmp/hdb;`trade;`price;2*]
```
#### Changes:
*Before:*
```q
q)select price from trade
price
--------
3747.242
4802.34
8547.059
9053.591
4328.193
..
```
*After:*
```q
q)select price from trade
price
--------
7494.484
9604.679
17094.12
18107.18
8656.387
..
```

### `listCols`
List the columns **from the first partition** of the existing table (`tabName`)
on the hdb directory (`hdbDir`)
```q
/ @usage
listCols[hdbDir;tabName]
/ @example
listCols[`:tmp/hdb;`trade]
```
***Output:***
```q
2025.09.20D09:06:55.678017279 [INFO]: Table [trade] columns:
`sym`time`price`noo`size2
```

## renameCol
Rename the existing column (`oldName`)
to the new column (`newName`)
of the existing table (`tabName`)
on the hdb directory (`hdbDir`)
> [!WARNING]
> TODO: Does not support nested columns currently
```q
/ @usage
renameCol[hdbDir;tabName;oldName;newName]
/ @example
renameCol[`:tmp/hdb;`trade;`size2;`size]
```
#### Changes:
*Directory:*
```sh
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.02
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.03
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── sym
│       └── time
└── sym
```
*meta:*
```q
c    | t f a
-----| -----
date | d
sym  | s
time | p
price| f
noo  | h
size | h
```

### `reorderCols`
Reorder the existing table (`tabName`)
to the new order of existing column names (`orderedColNames`)
on the hdb directory (`hdbDir`)
```q
/ @usage
reorderCols[hdbDir;tabName;orderedColNames]
/ @example
reorderCols[`:tmp/hdb;`trade;reverse`sym`time`price`noo`size]
```
#### Changes:
*meta:*
```q
c    | t f a
-----| -----
date | d
size | h
noo  | h
price| f
time | p
sym  | s
```

### `setAttrCol`
Apply a new attribute (`newAttr`)
to the existing column (`colName`)
of the existing table (`tabName`)
on the hdb directory (`hdbDir`)
> [!NOTE]
> The values in the column must be valid to apply the new attribute
> - Does not sort
```q
/ @usage
setAttrCol[hdbDir;tabName;colName;newAttr]
/ @example
setAttrCol[`:tmp/hdb;`trade;`sym;`g]
```
#### Changes:
*meta:*
```q
c    | t f a
-----| -----
date | d
size | h
noo  | h
price| f
time | p
sym  | s   g
```

### `addTab`
Add a new table (`tabName`)
with the schema (`tabSchema`)
on the hdb directory (`hdbDir`)
```q
/ @usage
addTab[hdbDir;tabName;tabSchema]
/ @example
addTab[`:tmp/hdb;`trade1;([]time:0#0Nt;sym:0#`;price:0#0n;size:0#0)]
```
#### Changes:
*Directory:*
```sh
tmp/hdb
├── 2023.01.01
│   ├── trade
│   │   ├── noo
│   │   ├── price
│   │   ├── size
│   │   ├── sym
│   │   └── time
│   └── trade1
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.02
│   ├── trade
│   │   ├── noo
│   │   ├── price
│   │   ├── size
│   │   ├── sym
│   │   └── time
│   └── trade1
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.03
│   ├── trade
│   │   ├── noo
│   │   ├── price
│   │   ├── size
│   │   ├── sym
│   │   └── time
│   └── trade1
│       ├── price
│       ├── size
│       ├── sym
│       └── time
└── sym
```

### `renameTab`
Rename the existing table (`oldName`)
to the new table (`newName`)
on the hdb directory (`hdbDir`)
```q
/ @usage
renameTab[hdbDir;oldName;newName]
/ @example
renameTab[`:tmp/hdb;`trade1;`trade2]
```
#### Changes:
*Directory:*
```sh
tmp/hdb
├── 2023.01.01
│   ├── trade
│   │   ├── noo
│   │   ├── price
│   │   ├── size
│   │   ├── sym
│   │   └── time
│   └── trade2
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.02
│   ├── trade
│   │   ├── noo
│   │   ├── price
│   │   ├── size
│   │   ├── sym
│   │   └── time
│   └── trade2
│       ├── price
│       ├── size
│       ├── sym
│       └── time
├── 2023.01.03
│   ├── trade
│   │   ├── noo
│   │   ├── price
│   │   ├── size
│   │   ├── sym
│   │   └── time
│   └── trade2
│       ├── price
│       ├── size
│       ├── sym
│       └── time
└── sym
```
