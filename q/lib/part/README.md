# part.q

Script to create mock int, date, month and year partitioned databases

The following globals can be modified:
```q
.part.numTrade:1000; / Total number of trades
.part.numPart:10;    / Total number of partitions
.part.rmForce:1b;    / Force remove destination path if it already exists
.part.dest:`:part;   / Destination path
```

Use `.part.genData[]` to create the partitioned databases

With the defaults, the `part` (partitioned) directory is about `1.4M`.

Directory structure:
```
part
├── date
│   └── hdb
│       ├── 2025.04.15
│       │   └── trade
│       │       ├── price
│       │       ├── size
│       │       ├── sym
│       │       └── time
│       ├── 2025.04.16
.       .   └── ...
│       └── sym
├── int
│   └── hdb
│       ├── 221870
.       .   └── ...
│       ├── 221871
.       .   └── ...
│       └── sym
├── month
│   └── hdb
│       ├── 2024.07
.       .   └── ...
│       ├── 2024.08
.       .   └── ...
│       └── sym
└── year
    └── hdb
        ├── 2016
        .   └── ...
        ├── 2017
        .   └── ...
        └── sym
```

Loading the hdbs:
```q
$ q part/int/hdb
q)\v
`int`sym`trade
q)select count i by int from trade
int   | x
------| ---
221870| 97
221871| 106
..
q)meta trade // NOTE: int is long type
c    | t f a
-----| -----
int  | j
sym  | s   p
price| f
size | j
time | p

$ q part/date/hdb
q)\v
`date`sym`trade
q)select count i by date from trade
date      | x
----------| ---
2025.04.15| 96
2025.04.16| 85
..
q)meta trade
c    | t f a
-----| -----
date | d
..

$ q part/month/hdb
q)\v
`month`sym`trade
q)select count i by month from trade
month  | x
-------| ---
2024.07| 101
2024.08| 88
..
q)meta trade
c    | t f a
-----| -----
month| m
..

$ q part/year/hdb
q)\v
`sym`trade`year
q)select count i by year from trade
year| x
----| ---
2016| 96
2017| 100
..
q)meta trade
c    | t f a
-----| -----
year | j
..
```
