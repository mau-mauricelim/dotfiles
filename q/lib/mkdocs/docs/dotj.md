# The .j namespace

```txt
https://code.kx.com/q/ref/dotj/#the-j-namespace

The .j namespace
+-------+--------------------+
| .j.j  | serialize          |
| .j.k  | deserialize        |
| .j.jd | serialize infinity |
+-------+--------------------+
The .j namespace contains functions for converting between JSON and q dictionaries.

.j.k (deserialize)
+------------------------------------------------------------------+
| q)show dict:`a`b!(0 1;("hello";"world"))                         |
| a| 0       1                                                     |
| b| "hello" "world"                                               |
| q).j.j dict                                                      |
| "{\"a\":[0,1],\"b\":[\"hello\",\"world\"]}"                      |
| q)-1 .j.j dict;                                                  |
| {"a":[0,1],"b":["hello","world"]}                                |
| q).j.k .j.j dict                                                 |
| a| 0       1                                                     |
| b| "hello" "world"                                               |
| q)show tab:([]a:1 2;b:`Greetings`Earthlings)                     |
| a b                                                              |
| ------------                                                     |
| 1 Greetings                                                      |
| 2 Earthlings                                                     |
| q).j.j tab                                                       |
| "[{\"a\":1,\"b\":\"Greetings\"},{\"a\":2,\"b\":\"Earthlings\"}]" |
| q).j.k .j.j tab                                                  |
| a b                                                              |
| --------------                                                   |
| 1 "Greetings"                                                    |
| 2 "Earthlings"                                                   |
+------------------------------------------------------------------+

Reading JSON data into a K (kdb) object
+--------------------------------+
| q)`:tab.json 0:enlist .j.j tab |
| `:tab.json                     |
| q).j.k raze read0`:tab.json    |
| a b                            |
| --------------                 |
| 1 "Greetings"                  |
| 2 "Earthlings"                 |
| q).j.k read1`:tab.json         |
| a b                            |
| --------------                 |
| 1 "Greetings"                  |
| 2 "Earthlings"                 |
+--------------------------------+
```
