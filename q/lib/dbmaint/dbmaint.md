# dbmaint _(Database maintenance)_
TODO

The script [dbmaint.q](dbmaint.q) contains utility functions for maintenance of partitioned database tables in kdb+.
It should not be used for splayed tables which are not partitioned, tables stored as single files or in memory tables.

You should always check the effect of using these functions on a test database first.
To test you can create a sample taq database with <https://github.com/KxSystems/kdb/blob/master/tq.q>,
but note that you should test on a sample of your own database before attempting to use any of these functions in production.

A few of the functions either do not support nested columns or can only be used for certain nested types, these are noted below.

If you are making changes to current database you need to reload (`\l .`) to make modifications visible.

If the database you've been modifying is a tick database, remember to adjust the schema to reflect your changes to the data.

In the following:
- `hdbDir`: a file symbol for the database folder
- `tabName`: the symbol naming a table
- `colName`: the symbol name of a column

**Examples:**

The examples in this document use a `trade` dir generated with the following sample data.
```q
n:1000;
trade:`sym`time xasc([]time:2023.01.01+n?3D;sym:n?`3;price:n?10000f;size:n?10000);
g:trade group`date$trade`time;
hdbDir:`:tmp/hdb;
{[d;p;t].Q.dd[d;p,`trade`]set .Q.en[d;@[t;`sym;`p#]]}[hdbDir]'[key g;g];
```

_on disk_
```txt
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

_meta_
```txt
c    | t f a
-----| -----
date | d
time | p
sym  | s   p
price| f
size | j
```

## addCol

`addCol[hdbDir;tabName;colName;defaultVal]`

Adds new column `colName` to `tabName` with value `defaultvalue` in each row.

**Example:**
```q
addCol[`:tmp/hdb;`trade;`noo;0h]
```

**Changes:**

_on disk_
```txt
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── noo
│       ├── price
│       ├── size
│       ├── sym
│       └── time
└── sym
```

_meta_
```txt
c    | t f a
-----| -----
date | d
sym  | s   p
time | t
price| f
size | j
noo  | h
```

## castCol

`castCol[hdbDir;tabName;colName;newType]`

Cast the values in the column to the `newType` and save. `newType` can be specified in short or long form, e.g. `"f"` or `` `float `` for a cast to float. This can be used to cast nested types as well, but to cast a nested character column to symbol use `fncol` instead.

**Example:**
```q
castCol[`:tmp/hdb;`trade;`size;`short]
```

**Changes:**

_meta_
```txt
c    | t f a
-----| -----
date | d
sym  | s   p
time | t
price| f
size | h
```

## clearAttrCol

`clearAttrCol[hdbDir;tabName;colName]`

Remove any attributes from column `colName`.

**Example:**
```q
clearAttrCol[`:tmp/hdb;`trade;`sym]
```

**Changes:**

_meta_

```txt
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

Copy the values from `oldName` into a new column named `newName`, undefined in the table. This does not support nested columns.

**Example:**
```q
copyCol[`:tmp/hdb;`trade;`size;`size2]
```

**Changes:**

_on disk_
```txt
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

```txt
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

## deletecol

`deletecol[hdbDir;tabName;colName]`

Delete column `colName` from `tabName`.

This doesn't delete the colName# files for nested columns (the files containing the actual values) – you will need to delete these manually.

**Example:**.
```q
deletecol[`:tmp/hdb;`trade;`size]
```

**Changes:**

_on disk_
```txt
tmp/hdb
├── 2023.01.01
│   └── trade
│       ├── price
│       ├── sym
│       └── time
└── sym
```

_meta_
```txt
c    | t f a
-----| -----
date | d
sym  | s   p
time | t
price| f
```


## findcol

`findcol[hdbDir;tabName;colName]`

Print a list of the partition directories where `colName` exists and its type in each, and a `*NOT*FOUND*` message for partition directories where `colName` is missing.

**Example:**
```q
findcol[`:tmp/hdb;`trade;`iz]
```

**Output:**
```txt
2023.02.17 10:23:09 column iz *NOT*FOUND* in `:tmp/hdb/2023.01.01/trade
```

## fixtable

`fixtable[hdbDir;tabName;goodpartition]`

Adds missing columns to to all partitions of a table, given the location of a good partition. This _doesn't_ delete extra columns – do that manually. Also this does not add tables to partitions in which they are missing, use [`.Q.chk`](https://code.kx.com/q/ref/dotq/#qchk-fill-hdb) for that.

**Example:**
```q
`:tmp/hdb/2023.01.02/trade/ set .Q.en[`:tmp/hdb] delete size from trade;
fixtable[`:tmp/hdb;`trade;`:tmp/hdb/2023.01.01/trade]
```

**Changes:**

_on disk_
```txt
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


## fncol

`fncol[hdbDir;tabName;colName;fn]`

Apply a function to the list of values in `colName` and save the results as its values.

**Example:**
```q
fncol[`:tmp/hdb;`trade;`price;2*]
```

**Changes:**

_before_
```txt
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

```txt
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


## listcols

`listcols[hdbDir;tabName]`

List the columns of `tabName` (relies on the first partition).

**Example:**
```q
listcols[`:tmp/hdb;`trade]
```

**Output:**
```txt
`sym`time`price`size
```

## renamecol

`renamecol[hdbDir;tabName;oldname;newname]`

Rename column `oldname` to `newname`, which must be undefined in the table. This does not support nested columns.

**Example:**
```q
renamecol[`:tmp/hdb;`trade;`woz;`iz]
```

**Changes:**

_on disk_
```txt
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
```txt
c    | t f a
-----| -----
date | d
sym  | s   p
time | t
price| f
size | j
```

## reordercols

`reordercols[hdbDir;tabName;neworder]`

Reorder the columns of `tabName`. `neworder` is a full list of the column names as they appear in the updated table.

**Example:**
```q
reordercols[`:tmp/hdb;`trade;reverse cols trade]
```
**Changes:**

_meta_
```txt
c    | t f a
-----| -----
date | d
size | j
price| f
sym  | s   p
time | t
```


## setattrcol

`setattrcol[hdbDir;tabName;colName;newattr]`

Apply an attribute to `colName`. The data in the column must be valid for that attribute. No sorting occurs.

**Example:**
```q
setattrcol[`:tmp/hdb;`trade;`sym;`g]
```

**Changes:**

_meta_
```txt
c    | t f a
-----| -----
date | d
sym  | s   g
time | t
price| f
size | j
```

## addtable

`addtable[hdbDir;tabName;tabSchema]`

Add a table called `tabName` with an empty table with the same schema as `tabSchema` created in each partition of the new table.

**Example:**
```q
addtable[`:tmp/hdb;`trade1;.Q.en[`:tmp/hdb]([]time:0#0Nt;sym:0#`;price:0#0n;size:0#0)]
```

**Changes:**

_on disk_
```txt
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

## rentable

`rentable[hdbDir;old;new]`

Rename table `old` to `new`.

**Example:**
```q
rentable[`:tmp/hdb;`trade;`transactions]
```

**Changes:**

_on disk_
```txt
tmp/hdb
├── 2023.01.01
│   └── transactions
│       ├── price
│       ├── size
│       ├── sym
│       └── time
└── sym
```
