# 🧸 qute _(q unit tests)_
Unit testing framework in q/kdb

## 🚀 Usage
To use qute, simply load the library:
```q
q).lib.require`qute / Loads the qute library
```
### Test files
Tests should be written in a (delimiter-separated values) `dsv` file
- File name should be in the following format: `qute.*.dsv`
- Default delimiter is a pipe (`|`) which can be updated in `.qute.delim`
```dsv
action | minver | code | repeat | ms | bytes | comment
```

Column description:
```md
| column  | description                            | comment                                                  |
| -       | -                                      | -                                                        |
| action  | beforeany                              | run code ONCE BEFORE ANY TESTS                           |
|         |     beforeeach                         | run code      BEFORE any tests in EACH FILE              |
|         |         before                         | run code      BEFORE any tests in THIS FILE ONLY         |
|         |         run                            | run code                                                 |
|         |         true                           | run code: expects result to return true (1b)             |
|         |         fail                           | run code: expects result to fail (2+`two)                |
|         |         after                          | run code      AFTER  all tests in THIS FILE ONLY         |
|         |     aftereach                          | run code      AFTER  all tests in EACH FILE              |
|         | afterall                               | run code ONCE AFTER  ALL TESTS, use for cleanup/finalise |
| minver  | minimum version of kdb+ (.z.K)         | default 0.                                               |
| code    | code to be executed                    |                                                          |
| repeat  | number of repetitions                  | default 1i                                               |
| ms      | max milliseconds it should take to run | default 0i => ignore                                     |
| bytes   | bytes it should take to run            | default 0i => ignore                                     |
| comment | description of the test                |                                                          |
```
