# 🛠️ dbmaint _(Database maintenance)_
TODO

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

Directory:
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

meta:
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

Directory:
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

meta:
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
castCol[hdbDir;tabName;colName;newType]
castCol[`:tmp/hdb;`trade;`size;`short]
```
meta:
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

TODO: Continue from here

## clearAttrCol

`clearAttrCol[hdbDir;tabName;colName]`

Remove any attributes from column `colName`.

**Example:**
```q
clearAttrCol[`:tmp/hdb;`trade;`sym]
```

**Changes:**

_meta_

```q
c    | t f a
-----| -----
date | d
sym  | s
time | t
price| f
size | j
```

## copyCol

`copyCol[hdbDir;tabName;oldName;newName]`

Copy the values from column `oldName` into a new column named `newName`, undefined in the table `tabName`.

TODO
This does not support nested columns.

**Example:**
```q
copyCol[`:tmp/hdb;`trade;`size;`size2]
```

**Changes:**

_on disk_
```sh
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── price
│       ├── size
│       ├── size2
│       ├── sym
│       └── time
└── sym
```

_meta_
```q
meta
c    | t f a
-----| -----
date | d
sym  | s   p
time | t
price| f
size | j
size2| j
```

## deleteCol

`deleteCol[hdbDir;tabName;colName]`

Delete column `colName` from table `tabName`.

TODO
This doesn't delete the `colName#` files for nested columns (the files containing the actual values) - you will need to delete these manually.

**Example:**.
```q
deleteCol[`:tmp/hdb;`trade;`size]
```

**Changes:**

_on disk_
```sh
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── price
│       ├── sym
│       └── time
└── sym
```

_meta_
```q
c    | t f a
-----| -----
date | d
sym  | s   p
time | t
price| f
```


## findCol

`findCol[hdbDir;tabName;colName]`

TODO
Print a list of the partition directories where column `colName` exists and its type in each,
and a `*NOT*FOUND*` message for partition directories where column `colName` is missing.

**Example:**
```q
findCol[`:tmp/hdb;`trade;`iz]
```

**Output:**
```sh
2023.02.17 10:23:09 column iz *NOT*FOUND* in `:tmp/hdb/2023.01.01/trade
```

## fixTab

`fixTab[hdbDir;tabName;goodPartition]`

Given the location of a good partition `goodPartition`:
- Adds missing
- Deletes extra
- Reorder
columns to to all partitions of `tabName`

TODO
Also this does not add tables to partitions in which they are missing, use [`.Q.chk`](https://code.kx.com/q/ref/dotq/#qchk-fill-hdb) for that.

**Example:**
```q
`:tmp/hdb/2023.01.02/trade/ set .Q.en[`:tmp/hdb] delete size from trade;
fixTab[`:tmp/hdb;`trade;2023.01.01]
```

**Changes:**

_on disk_
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
└── sym
```

## funcCol

`funcCol[hdbDir;tabName;colName;func]`

Apply a function to the list of values in `colName` and save the results as its values.

**Example:**
```q
funcCol[`:tmp/hdb;`trade;`price;2*]
```

**Changes:**

_before_
```q
q)select price from trade
price
--------
4812.041
1399.557
9491.982
5034.046
4882.605
...
```

_after_
```q
q)select price from trade
price
--------
9624.081
2799.113
18983.96
10068.09
9765.209
...
```

## listCols

`listCols[hdbDir;tabName]`

List the columns of `tabName` (relies on the first partition).

**Example:**
```q
listCols[`:tmp/hdb;`trade]
```

**Output:**
```q
`sym`time`price`size
```

## renameCol

`renameCol[hdbDir;tabName;oldName;newName]`

TODO
Rename column `oldName` to `newName`, which must be undefined in the table. This does not support nested columns.

**Example:**
```q
renameCol[`:tmp/hdb;`trade;`woz;`iz]
```

**Changes:**

_on disk_
```sh
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── price
│       ├── size
│       ├── sym
│       └── time
└── sym
```

_meta_
```q
c    | t f a
-----| -----
date | d
sym  | s   p
time | t
price| f
size | j
```

## reorderCols

`reorderCols[hdbDir;tabName;orderedColNames]`

Reorder the columns of `tabName`. `orderedColNames` is a full list of the column names as they appear in the updated table.

**Example:**
```q
reorderCols[`:tmp/hdb;`trade;reverse cols trade]
```
**Changes:**

_meta_
```q
c    | t f a
-----| -----
date | d
size | j
price| f
sym  | s   p
time | t
```

## setAttrCol

`setAttrCol[hdbDir;tabName;colName;newAttr]`

Apply an attribute to `colName`. The data in the column must be valid for that attribute. No sorting occurs.

**Example:**
```q
setAttrCol[`:tmp/hdb;`trade;`sym;`g]
```

**Changes:**

_meta_
```q
c    | t f a
-----| -----
date | d
sym  | s   g
time | t
price| f
size | j
```

## addTab

`addTab[hdbDir;tabName;tabSchema]`

Add a table called `tabName` with an empty table with the same schema as `tabSchema` created in each partition of the new table.

**Example:**
```q
addTab[`:tmp/hdb;`trade1;.Q.en[`:tmp/hdb]([]time:0#0Nt;sym:0#`;price:0#0n;size:0#0)]
```

**Changes:**

_on disk_
```sh
tmp/hdb
├── 2023.01.01
│   ├── trade
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

## renameTab

`renameTab[hdbDir;oldName;newName]`

Rename table `oldName` to `newName`.

**Example:**
```q
renameTab[`:tmp/hdb;`trade;`transactions]
```

**Changes:**

_on disk_
```sh
tmp/hdb
├── 2023.01.01
│   └── transactions
│       ├── price
│       ├── size
│       ├── sym
│       └── time
└── sym
```
