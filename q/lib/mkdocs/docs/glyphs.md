# Overloaded glyphs

```txt
https://code.kx.com/q/ref/overloads/#overloaded-glyphs

Overloaded glyphs
- Many non-alphabetic keyboard characters are overloaded. Operator overloads are resolved by rank, and sometimes by the type of argument/s.

@ at
+------+-------------+------------+
| rank | syntax      | semantics  |
+------+-------------+------------+
| 2    | l@i, @[l;i] | Index At   |
| 2    | f@y, @[f;y] | Apply At   |
| 3    | @[f;y;e]    | Trap At    |
| 3    | @[d;i;u]    | Amend At   |
| 4    | @[d;i;m;my] | Amend At   |
| 4    | @[d;i;:;y]  | Replace At |
+------+-------------+------------+

\ backslash
+------+----------------------+------------------------+    legend
| rank | syntax               | semantics              |    +----------------------------------------+
+------+----------------------+------------------------+    | d         | data                       |
| NA   | \                    | ends multiline comment |    | u         | unary value                |
| NA   | \                    | Abort, Toggle          |    | v         | value rank>1               |
| 1    | (u\), u\[d]          | Converge               |    | n         | non-negative integer atom  |
| 2    | n u\d, u\[n;d]       | Do                     |    | t         | test value                 |
| 2    | t u\d, u\[t;d]       | While                  |    | x         | atom or vector             |
| 2    | x v\y, v\[x;y;z;...] | map-reduce             |    | y, z, ... | conformable atoms or lists |
+------+----------------------+------------------------+    +----------------------------------------+

! bang
+------+------------+----------------------------------+    legend
| rank | syntax     | semantics                        |    +-------+------------------------------------------+
+------+------------+----------------------------------+    | a     | select specifications                    |
| 2    | x!y        | Dict: make a dictionary          |    | b     | group-by specifications                  |
| 2    | i!ts       | Enkey: make a simple table keyed |    | c     | where-specifications                     |
| 2    | 0!tk       | Unkey: make a keyed table simple |    | h     | handle to a splayed or partitioned table |
| 2    | noasv!iv   | Enumeration from index           |    | i     | integer >0                               |
| 2    | sv!h       | Flip Splayed or Partitioned      |    | noasv | symbol atom, the name of a symbol vector |
| 2    | 0N!y       | display y and return it          |    | sv    | symbol vector                            |
| 2    | -i!y       | internal function                |    | t     | table                                    |
| 4    | ![t;c;b;a] | Update, Delete                   |    | tk    | keyed table                              |
+------+------------+----------------------------------+    | ts    | simple table                             |
                                                            | x,y   | same-length lists                        |
                                                            +-------+------------------------------------------+

: colon
+---------+-----------------+
| literal | semantics       |
+---------+-----------------+
| a:42    | assign          |
| :42     | explicit return |
+---------+-----------------+

:: colon colon
+-------------------------------+-------------------------------------+
| literal                       | semantics                           |
+-------------------------------+-------------------------------------+
| v::select from t where a in b | define a view                       |
| global::42                    | amend a global from within a lambda |
| ::                            | Identity                            |
| ::                            | Null                                |
+-------------------------------+-------------------------------------+

- dash
+------+---------+-----------------+    legend
| rank | example | semantics       |    +----------------------------------------+
+------+---------+-----------------+    | n         | non-negative integer atom  |
| NA   | -n      | Negative number |    +----------------------------------------+
| 2    | 2-3     | Subtract        |
+------+---------+-----------------+

. dot
+------+-----------------+------------+
| rank | syntax          | semantics  |
+------+-----------------+------------+
| NA   | .               | Push stack |
| 2    | l . i, .[l;i]   | Index      |
| 2    | g . gx, .[g;gx] | Apply      |
| 3    | .[g;gx;e]       | Trap       |
| 3    | .[d;i;u]        | Amend      |
| 4    | .[d;i;m;my]     | Amend      |
| 4    | .[d;i;:;y]      | Replace    |
+------+-----------------+------------+

$ dollar
+------+-------------------------------------+-----------------------------------+
| rank | example                             | semantics                         |
+------+-------------------------------------+-----------------------------------+
| 3    | $[x>10;y;z]                         | Cond: conditional evaluation      |
| 2    | "h"$y, `short$y, 11h$y              | Cast: cast datatype               |
| 2    | "H"$y, -11h$y                       | Tok: interpret string as data     |
| 2    | x$y                                 | Enumerate: enumerate y from x     |
| 2    | 10$"abc"                            | Pad: pad string                   |
| 2    | (1 2 3f;4 5 6f)$(7 8f;9 10f;11 12f) | dot product, matrix multiply, mmu |
+------+-------------------------------------+-----------------------------------+

# hash
+------+-----------+---------------+
| rank | example   | semantics     |
+------+-----------+---------------+
| 2    | 2 3#til 6 | Take          |
| 2    | s#1 2 3   | Set Attribute |
+------+-----------+---------------+

? query
+------+---------------------------+------------------------------------+
| rank | example                   | semantics                          |
+------+---------------------------+------------------------------------+
| 2    | "abcdef"?"cab"            | Find y in x                        |
| 2    | 10?1000, 5?01b            | Roll                               |
| 2    | -10?1000, -1?`yes`no      | Deal                               |
| 2    | 0N?1000, 0N?`yes`no       | Permute                            |
| 2    | x?v                       | extend an enumeration: Enum Extend |
| 3    | ?[11011b;"black";"flock"] | Vector Conditional                 |
| 3    | ?[t;i;p]                  | Simple Exec                        |
| 4    | ?[t;c;b;a]                | Select, Exec                       |
| 5    | ?[t;c;b;a;n]              | Select                             |
| 6    | ?[t;c;b;a;n;(g;cn)]       | Select                             |
+------+---------------------------+------------------------------------+

' quote
+------+----------------------------------+-----------------------------------+    legend
| rank | syntax                           | semantics                         |    +------+-------------------+
+------+----------------------------------+-----------------------------------+    | u    | unary value       |
| 1    | (u')x, u'[x], x b'y, v'[x;y;...] | Each: iterate u, b or v itemwise  |    | b    | binary value      |
| 1    | 'msg                             | Signal an error                   |    | v    | value of rank >=1 |
| 1    | int'[x;y;...]                    | Case: successive items from lists |    | int  | int vector        |
| 2    | '[u;v]                           | Compose u with v                  |    | msg  | symbol or string  |
+------+----------------------------------+-----------------------------------+    | x, y | data              |
                                                                                   +------+-------------------+

': quote-colon
+------+---------+----------------------------+
| rank | example | semantics                  |
+------+---------+----------------------------+
| 1    | u':     | Each Parallel with unary u |
| 1    | b':     | Each Prior with binary b   |
+------+---------+----------------------------+

/ slash
+------+--------------------------+------------------------------------+    legend
| rank | syntax                   | semantics                          |    +---+------------------------+
+------+--------------------------+------------------------------------+    | u | unary value            |
| NA   | /comment line            | comment: ignore entire line        |    | v | value rank >=1         |
| NA   | <code> /trailing comment | comment: ignore trailing line      |    | n | non-negative int atom  |
| 1    | (u/)y, u/[y]             | Converge                           |    | t | test value             |
| 1    | n u/ y, u/[n;y]          | Do                                 |    | y | list                   |
| 1    | t u/ y, u/[t;y]          | While                              |    +---+------------------------+
| 1    | (v/)y, v/[y]             | map-reduce: reduce a list or lists |
+------+--------------------------+------------------------------------+
- In a script, a line with a solitary / marks the beginning of a multiline comment.
- A multiline comment is terminated by a \ or the end of the script.

_ underscore
+------+-----------+-----------+
| rank | example   | semantics |
+------+-----------+-----------+
| 2    | 3_ til 10 | Cut, Drop |
+------+-----------+-----------+
- Names can contain underscores
- Best practice is to use a space to separate names and the Cut and Drop operators.
```
