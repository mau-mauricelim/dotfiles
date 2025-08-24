# Debugging

```txt
https://code.kx.com/q/basics/debug/#debugging

Debugging
+----------+-----------------------------------------------+
| q))      | extra right parens mark suspended execution/s |
| 'myerror | Signal error, cut back stack                  |
| :r       | exit suspended function with r as result      |
| \        | abort execution and exit debugger             |
| .Q.bt    | dump backtrace                                |
| &        | current frame information                     |
| .Q.trp   | extends Trap At to collect backtrace          |
| -e \e    | error-trap mode                               |
+----------+-----------------------------------------------+

Debugger
- Usually when an error happens inside a lambda the execution is suspended and you enter the debugger,
  as indicated by the additional ) following the normal q) prompt.
+---------------------------------------------------------------------------------------------------+
| q)f:{g[x;2#y]}                                                                                    |
| q)g:{a:x*2;a+y}                                                                                   |
| q)f[3;"hello"]                                                                                    |
| 'type                                                                                             |
|   [2]  g:{a:x*2;a+y}                                                                              |
|                  ^                                                                                |
+---------------------------------------------------------------------------------------------------+
| q)).Q.bt[]              / Dump the backtrace to stdout. Highlight current stack frame with >>.    |
| >>[2]  g:{a:x*2;a+y}                                                                              |
|                  ^                                                                                |
|   [1]  f:{g[x;2#y]}                                                                               |
|           ^                                                                                       |
|   [0]  q)f[3;"hello"]                                                                             |
|          ^                                                                                        |
| q))&                    / Current frame information                                               |
| 'type                                                                                             |
|   [2]  g:{a:x*2;a+y}                                                                              |
|                  ^                                                                                |
+---------------------------------------------------------------------------------------------------+
| q))a*4                  / The debug prompt allows operating on values defined in the local scope. |
| 24                                                                                                |
+---------------------------------------------------------------------------------------------------+
| q))`                    / Navigate up the stack                                                   |
|   [1]  f:{g[x;2#y]}                                                                               |
|           ^                                                                                       |
| q))`                                                                                              |
|   [0]  f[3;"hello"]                                                                               |
|        ^                                                                                          |
| q)).                    / Navigate down the stack                                                 |
|   [1]  f:{g[x;2#y]}                                                                               |
|          ^                                                                                        |
+---------------------------------------------------------------------------------------------------+
| q)).z.ex                / Failed primitive                                                        |
| +                                                                                                 |
| q)).z.ey                / Argument list                                                           |
| 6                                                                                                 |
| "he"                                                                                              |
+---------------------------------------------------------------------------------------------------+
| q))'myerror             / 'err will signal err from the deepest frame available, destroying it.   |
| 'myerror                                                                                          |
|   [1]  f:{g[x;2#y]}                                                                               |
|           ^                                                                                       |
| q))'myerror                                                                                       |
| 'myerror                                                                                          |
|   [0]  f[3;"hello"]                                                                               |
|        ^                                                                                          |
| q)'myerror                                                                                        |
| 'myerror                                                                                          |
|   [0]  'myerror                                                                                   |
|         ^                                                                                         |
| q)                                                                                                |
+---------------------------------------------------------------------------------------------------+

Resume
- When execution is suspended, :e resumes with e as the result of the failed operation. e defaults to null ::.
- Note that resume does not return from enclosing function

Error trap modes
- At any point during execution, the behavior of Signal (') is determined by the internal error-trap mode:
+---+-----------------------------------------------+
| 0 | abort execution (set by Trap: @ or .)         |
| 1 | suspend execution and run the debugger        |
| 2 | collect stack trace and abort (set by .Q.trp) |
+---+-----------------------------------------------+
```
