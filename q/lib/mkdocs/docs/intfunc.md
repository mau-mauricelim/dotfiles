# Internal functions

```txt
https://code.kx.com/q/basics/internal/#internal-functions

Internal functions
+-----------+------------------------------+----------------+
| 0N!x      | show                         | Replaced:      |
| -4!x      | tokens                       +----------------+
| -8!x      | to bytes                     | -1!  | hsym    |
| -9!x      | from bytes                   | -2!  | attr    |
| -10!x     | type enum                    | -3!  | .Q.s1   |
| -11!      | streaming execute            | -5!  | parse   |
| -14!x     | quote escape                 | -6!  | eval    |
| -16!x     | ref count                    | -7!  | hcount  |
| -18!x     | compress bytes               | -12! | .Q.host |
| -21!x     | compression/encryption stats | -13! | .Q.addr |
| -22!x     | uncompressed length          | -15! | md5     |
| -23!x     | memory map                   | -19! | set     |
| -25!x     | async broadcast              | -20! | .Q.gc   |
| -26!x     | SSL                          | -24! | reval   |
| -27!(x;y) | format                       | -29! | .j.k    |
| -30!x     | deferred response            | -31! | .j.jd   |
| -33!x     | SHA-1 hash                   | -32! | .Q.btoa |
| -36!      | load master key              | -34! | .Q.ts   |
| -38!x     | socket table                 | -35! | .Q.gz   |
| -120!x    | memory domain                | -37! | .Q.prf0 |
+-----------+------------------------------+----------------+
```
