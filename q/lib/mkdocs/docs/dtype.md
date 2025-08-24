# Datatypes

```txt
https://code.kx.com/q/basics/datatypes/#datatypes

Basic datatypes

Columns:
n    short int returned by type and used for Cast, e.g. 9h$3 (negative for atoms of basic datatypes, positive for everything else)
c    character used lower-case for Cast and upper-case for Tok and Load CSV
sz   size in bytes
inf  infinity (no math on temporal types); 0Wh is 32767h
+-------+---+-----------------+----+-------------------------------+------+-----+-----------+-----------+---------------+
| n     | c | name            | sz | literal                       | null | inf | SQL       | Java      | .Net          |
+-------+---+-----------------+----+-------------------------------+------+-----+-----------+-----------+---------------+
| 0     | * | list            |    | ()                            |      |     |           |           |               |
| 1     | b | boolean         | 1  | 0b                            |      |     |           | Boolean   | boolean       |
| 2     | g | guid            | 16 |                               | 0Ng  |     |           | UUID      | GUID          |
| 4     | x | byte            | 1  | 0x00                          |      |     |           | Byte      | byte          |
| 5     | h | short           | 2  | 0h                            | 0Nh  | 0Wh | smallint  | Short     | int16         |
| 6     | i | int             | 4  | 0i                            | 0Ni  | 0Wi | int       | Integer   | int32         |
| 7     | j | long            | 8  | 0j                            | 0Nj  | 0Wj | bigint    | Long      | int64         |
|       |   |                 |    | 0                             | 0N   | 0W  |           |           |               |
| 8     | e | real            | 4  | 0e                            | 0Ne  | 0We | real      | Float     | single        |
| 9     | f | float           | 8  | 0.0                           | 0n   | 0w  | float     | Double    | double        |
|       |   |                 |    | 0f                            | 0Nf  |     |           |           |               |
| 10    | c | char            | 1  | " "                           | " "  |     |           | Character | char          |
| 11    | s | symbol          |    | `                             | `    |     | varchar   |           |               |
| 12    | p | timestamp       | 8  | 2000.01.01D00:00:00.000000000 | 0Np  | 0Wp |           | Timestamp | DateTime (RW) |
| 13    | m | month           | 4  | 2000.01m                      | 0Nm  | 0Wm |           |           |               |
| 14    | d | date            | 4  | 2000.01.01                    | 0Nd  | 0Wd | date      | Date      |               |
| 15    | z | datetime        | 8  | 2000.01.01T00:00:00.000       | 0Nz  | 0wz | timestamp | Timestamp | DateTime (RO) |
| 16    | n | timespan        | 8  | 00:00:00.000000000            | 0Nn  | 0Wn |           | Timespan  | TimeSpan      |
| 17    | u | minute          | 4  | 00:00                         | 0Nu  | 0Wu |           |           |               |
| 18    | v | second          | 4  | 00:00:00                      | 0Nv  | 0Wv |           |           |               |
| 19    | t | time            | 4  | 00:00:00.000                  | 0Nt  | 0Wt | time      | Time      | TimeSpan      |
+-------+---+-----------------+----+-------------------------------+------+-----+-----------+-----------+---------------+
| 20-76 |   | enums           |    | `zym$10?zym:`AAPL`GOOG`IBM    |      |     |           |           |               |
+-------+---+-----------------+----+-------------------------------+------+-----+-----------+-----------+---------------+
| 78-96 |   | 77+t - mapped (nested) list of lists of type t       |      |     |           |           |               |
|       |   | e.g. 78 is boolean. 96 is time.                      |      |     |           |           |               |
+-------+---+-----------------+----+-------------------------------+------+-----+-----------+-----------+---------------+
| 77    |   | anymap          |    | get`:a set (1 2 3;"cde")      |      |     |           |           |               |
+-------+---+-----------------+----+-------------------------------+------+-----+-----------+-----------+---------------+
| 97    |   | nested sym enum |    |                               |      |     |           |           |               |
+-------+---+-----------------+----+-------------------------------+------+-----+-----------+-----------+---------------+
| 98    |   | table           |    | ([] c1:`a`b`c; c2:10 20 30)   |      |     |           |           |               |
| 99    |   | dictionary      |    | `a`b`c!10 20 30               |      |     |           |           |               |
|       |   |                 |    | ([a:10;b:20;c:30]) ([a:10])   |      |     |           |           |               |
| 100   |   | lambda          |    | {x}                           |      |     |           |           |               |
| 101   |   | unary primitive |    | (::) abs neg til ...          |      |     |           |           |               |
| 102   |   | operator        |    | . $ ! ? + - * %  ...          |      |     |           |           |               |
| 103   |   | iterator        |    | ' ': /: \: / \   ...          |      |     |           |           |               |
| 104   |   | projection      |    | 2* {x+y*z}[3;;4]              |      |     |           |           |               |
| 105   |   | composition     |    | ('[raze;string])              |      |     |           |           |               |
| 106   |   | f'              |    | ,'                            |      |     |           |           |               |
| 107   |   | f/              |    | +/                            |      |     |           |           |               |
| 108   |   | f\              |    | +\                            |      |     |           |           |               |
| 109   |   | f':             |    | :':                           |      |     |           |           |               |
| 110   |   | f/:             |    | +/:                           |      |     |           |           |               |
| 111   |   | f\:             |    | +\:                           |      |     |           |           |               |
| 112   |   | dynamic load    |    | `f 2:`f,1                     |      |     |           |           |               |
+-------+---+-----------------+----+-------------------------------+------+-----+-----------+-----------+---------------+
Above, f is an applicable value.

date.(year month week mm dd)
time.(minute second mm ss)
milliseconds: time mod 1000
```
