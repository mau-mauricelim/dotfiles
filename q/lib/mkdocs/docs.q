// NOTE: This q script was generated using mkdocs.q

/########
/# Docs #
/########

.docs.ref:()!()

.docs.ref[`cmdline]:"Command-line options and system commands";
.docs.docs.cmdline:(
    "https://code.kx.com/q/ref/#command-line-options-and-system-commands";
    "+-------+------------------------+----------+---------------------+";
    "| file  |                        |          |                     |";
    "| \\a    | tables                 | \\r       | rename              |";
    "| -b    | blocked                | -s \\s    | secondary processes |";
    "| \\b \\B | views                  | -S \\S    | random seed         |";
    "| -c \\c | console size           | -t \\t    | timer ticks         |";
    "| -C \\C | HTTP size              | \\ts      | time and space      |";
    "| \\cd   | change directory       | -T \\T    | timeout             |";
    "| \\d    | directory              | -u -U \\u | usr-pwd             |";
    "| -e \\e | error traps            | -u       | disable syscmds     |";
    "| -E \\E | TLS server mode        | \\v       | variables           |";
    "| \\f    | functions              | -w \\w    | memory              |";
    "| -g \\g | garbage collection     | -W \\W    | week offset         |";
    "| \\l    | load file or directory | \\x       | expunge             |";
    "| -l -L | log sync               | -z \\z    | date format         |";
    "| -o \\o | UTC offset             | \\1 \\2    | redirect            |";
    "| -p \\p | listening port         | \\_       | hide q code         |";
    "| -P \\P | display precision      | \\        | terminate           |";
    "| -q    | quiet mode             | \\        | toggle q/k          |";
    "| -r \\r | replicate              | \\\\       | quit                |";
    "+-------+------------------------+----------+---------------------+");

.docs.ref[`dtype]:"Datatypes";
.docs.docs.dtype:(
    "Basic datatypes";
    "+-------+---+-----------------+----+-------------------------------+------+-----+-----------+";
    "| n     | c | name            | sz | literal                       | null | inf | SQL       |";
    "+-------+---+-----------------+----+-------------------------------+------+-----+-----------+";
    "| 0     | * | list            |    | ()                            |      |     |           |";
    "| 1     | b | boolean         | 1  | 0b                            |      |     |           |";
    "| 2     | g | guid            | 16 |                               | 0Ng  |     |           |";
    "| 4     | x | byte            | 1  | 0x00                          |      |     |           |";
    "|       |   |                 |    |                               |      |     |           |";
    "| 5     | h | short           | 2  | 0h                            | 0Nh  | 0Wh | smallint  |";
    "| 6     | i | int             | 4  | 0i                            | 0Ni  | 0Wi | int       |";
    "| 7     | j | long            | 8  | 0j                            | 0Nj  | 0Wj | bigint    |";
    "|       |   |                 |    | 0                             | 0N   | 0W  |           |";
    "| 8     | e | real            | 4  | 0e                            | 0Ne  | 0We | real      |";
    "| 9     | f | float           | 8  | 0.0                           | 0n   | 0w  | float     |";
    "|       |   |                 |    | 0f                            | 0Nf  |     |           |";
    "| 10    | c | char            | 1  | \" \"                           | \" \"  |     |           |";
    "| 11    | s | symbol          |    | `                             | `    |     | varchar   |";
    "| 12    | p | timestamp       | 8  | 2000.01.01D00:00:00.000000000 | 0Np  | 0Wp |           |";
    "| 13    | m | month           | 4  | 2000.01m                      | 0Nm  | 0Wm |           |";
    "| 14    | d | date            | 4  | 2000.01.01                    | 0Nd  | 0Wd | date      |";
    "| 15    | z | datetime        | 8  | 2000.01.01T00:00:00.000       | 0Nz  | 0wz | timestamp |";
    "| 16    | n | timespan        | 8  | 00:00:00.000000000            | 0Nn  | 0Wn |           |";
    "| 17    | u | minute          | 4  | 00:00                         | 0Nu  | 0Wu |           |";
    "| 18    | v | second          | 4  | 00:00:00                      | 0Nv  | 0Wv |           |";
    "| 19    | t | time            | 4  | 00:00:00.000                  | 0Nt  | 0Wt | time      |";
    "|       |   |                 |    |                               |      |     |           |";
    "| 20-76 |   | enums           |    | `zym$10?zym:`AAPL`GOOG`IBM    |      |     |           |";
    "| 77    |   | anymap          |    | get`:a set (1 2 3;\"cde\")      |      |     |           |";
    "| 98    |   | table           |    | ([] c1:`a`b`c; c2:10 20 30)   |      |     |           |";
    "| 99    |   | dictionary      |    | `a`b`c!10 20 30               |      |     |           |";
    "| 100   |   | lambda          |    | {x}                           |      |     |           |";
    "| 101   |   | unary primitive |    | (::) abs neg til ...          |      |     |           |";
    "| 102   |   | operator        |    | . $ ! ? + - * %  ...          |      |     |           |";
    "| 103   |   | iterator        |    | ' ': /: \\: / \\   ...          |      |     |           |";
    "| 104   |   | projection      |    | 2* {x+y*z}[3;;4]              |      |     |           |";
    "| 105   |   | composition     |    | ('[raze;string])              |      |     |           |";
    "| 106   |   | f'              |    | ,'                            |      |     |           |";
    "| 107   |   | f/              |    | +/                            |      |     |           |";
    "| 108   |   | f\\              |    | +\\                            |      |     |           |";
    "| 109   |   | f':             |    | :':                           |      |     |           |";
    "| 110   |   | f/:             |    | +/:                           |      |     |           |";
    "| 111   |   | f\\:             |    | +\\:                           |      |     |           |";
    "| 112   |   | dynamic load    |    | `f 2:`f,1                     |      |     |           |";
    "+-------+---+-----------------+----+-------------------------------+------+-----+-----------+";
    "Columns:";
    "n    short int returned by type and used for Cast, e.g. 9h$3";
    "c    character used lower-case for Cast and upper-case for Tok and Load CSV";
    "sz   size in bytes";
    "inf  infinity (no math on temporal types); 0Wh is 32767h";
    "";
    "Other datatypes";
    "78-96   77+t \342\200\223 mapped list of lists of type t";
    "97      nested sym enum");

/ Set the keys of .docs.docs as global variables to modified functions of it's values (docs)
/ The modified function prints the docs to the console
{x set{x;.util.stdout y;}[;trim y]}.'flip(key;value)@\:.docs.docs _`;
