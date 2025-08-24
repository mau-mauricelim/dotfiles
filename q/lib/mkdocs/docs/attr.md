# Attributes

```txt
https://code.kx.com/q/ref/set-attribute/

Attributes
+------------+-----------+--------------------------+-------------------+--------------------------+    legend
| literal    | attribute | description              | datatype          | memory overhead in bytes |    +---+--------------------------+
+------------+-----------+--------------------------+-------------------+--------------------------+    | n | count of unique elements |
| `#`s#2 2 3 | none      | remove attribute         | list, dict, table |                          |    | u | unique element           |
| `s#2 2 3   | sorted    | items in ascending order | list, dict, table | 0                        |    +---+--------------------------+
| `u#2 4 5   | unique    | each item unique         | list              | 16*n                     |
| `p#2 2 1   | parted    | common values adjacent   | simple list       | (16+8)*u                 |
| `g#2 1 2   | grouped   | make a hash table        | list              | (16+8)*u+8*n             |
+------------+-----------+--------------------------+-------------------+--------------------------+
- Setting or unsetting an attribute other than sorted causes a copy of the object to be made.
- s, u and g are preserved on append in memory, if possible. Only s is preserved on append to disk.

Errors
+--------+--------------------------------------+
| s-fail | not sorted ascending                 |
| type   | tried to set u, p or g on wrong type |
| u-fail | not unique or not parted             |
+--------+--------------------------------------+

Sorted
- Setting the sorted attribute on a unkeyed table sets the parted attribute on the first column.
+-----------------------------------------------------------+
| q)meta`s#([] ti:00:00:00 00:00:01 00:00:03; v:98 98 100.) |
| c | t f a                                                 |
| --| -----                                                 |
| ti| v   p                                                 |
| v | f                                                     |
+-----------------------------------------------------------+

- Setting the sorted attribute on a dictionary (keyed table), where the key is already in sorted order,
  in order to obtain a step-function, sets the sorted attribute for the key but copies the outer object.
+-------------------------------------------------------------+
| q)meta`s#1!([] ti:00:00:00 00:00:01 00:00:03; v:98 98 100.) |
| c | t f a                                                   |
| --| -----                                                   |
| ti| v   s                                                   |
| v |                                                         |
+-------------------------------------------------------------+

Step dictionary (keyed table)
+--------------------------------------------------------+
| q)d:00:00:00 00:00:01 00:00:03!98 98 100               |
| q)d 00:00:02                                           |
| 0N                                                     |
| q)(`s#d)00:00:02                                       |
| 98                                                     |
| q)d:1!([] ti:00:00:00 00:00:01 00:00:03; v:98 98 100.) |
| q)d 00:00:02                                           |
| v|                                                     |
| q)(`s#d)00:00:02                                       |
| v| 98                                                  |
+--------------------------------------------------------+
```
