# 🎲 rand _(Random Data Generator)_

## Usage examples

### `.rand.schema`

Generate a table schema

> [!WARNING]
> Upper case letter (list) types are not enforced, use `.rand.schemaForce` instead

```q
q)show tab:.rand.schema[`date`sym`price;"dsE"]
date sym price
--------------
q)meta tab
c    | t f a
-----| -----
date | d
sym  | s
price|
q)`tab insert(.z.d;`IBM;20.52 20.86 20.83e)
,0
q)tab
date       sym price
--------------------------------
2025.11.18 IBM 20.52 20.86 20.83
q)meta tab
c    | t f a
-----| -----
date | d
sym  | s
price| E
```

### `.rand.schemaForce`

Generate a table schema with upper case letter (list) types enforced

> [!NOTE]
> Output of `.rand.schema` and `.rand.schemaForce` are identical if there are no upper case letter (list) types

> [!WARNING]
> Upper case letter (list) types are enforced but requires a single null type row

```q
q)show tab:.rand.schemaForce[`date`sym`price;"dsE"]
date sym price
--------------

q)meta tab
c    | t f a
-----| -----
date | d
sym  | s
price| E
```

### `.rand.table`

Generate a random `table`

> [!NOTE]
> Default values can be adjusted by modifying `.rand.typeDefaults` and `.rand.maxListCount`

```q
q).rand.table[`date`sym`price;"dsE";3]
date       sym  price
----------------------------------------------------
2013.02.10 ileb 54.59723 86.49262 31.14364 81.32478e
2008.02.24 bfan 12.91938 14.77547 27.4227 56.35053e
2017.05.24 aafe ,88.3823e
```

### `.rand.boolean`

Generate a random `boolean` value
```q
q).rand.boolean[]
1b
```

### `.rand.guid`

Generate a random `guid` value
```q
q).rand.guid[]
c40190f5-606b-4504-7cce-d31a3d8cf4b2
```

### `.rand.byte`

Generate a random `byte` value
```q
q).rand.byte[]
0xc6
```

### `.rand.short`

Generate a random `short` value
```q
q).rand.short[]
204h
```

### `.rand.int`

Generate a random `int` value
```q
q).rand.int[]
8403i
```

### `.rand.long`

Generate a random `long` value
```q
q).rand.long[]
992844
```

### `.rand.real`

Generate a random `real` value
```q
q).rand.real[]
8.840718e
```

### `.rand.float`

Generate a random `float` value
```q
q).rand.float[]
178.8229
```

### `.rand.char`

Generate a random `char` value
```q
q).rand.char[]
"y"
```

### `.rand.symbol`

Generate a random `symbol` value
```q
q).rand.symbol[]
`acja
```

### `.rand.timestamp`

Generate a random `timestamp` value
```q
q).rand.timestamp[]
2003.03.24D20:02:39.505726400
```

### `.rand.month`

Generate a random `month` value
```q
q).rand.month[]
2013.04m
```

### `.rand.date`

Generate a random `date` value
```q
q).rand.date[]
2007.12.22
```

### `.rand.datetime`

Generate a random `datetime` value
```q
q).rand.datetime[]
2012.06.02T15:45:50.100
```

### `.rand.timespan`

Generate a random `timespan` value
```q
q).rand.timespan[]
0D23:42:03.609439283
```

### `.rand.minute`

Generate a random `minute` value
```q
q).rand.minute[]
19:07
```

### `.rand.second`

Generate a random `second` value
```q
q).rand.second[]
12:23:29
```

### `.rand.time`

Generate a random `time` value
```q
q).rand.time[]
23:43:30.338
```
