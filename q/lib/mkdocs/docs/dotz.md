# The .z namespace

```txt
https://code.kx.com/q/ref/dotz/#the-z-namespace

The .z namespace
+------------------------------------------+---------------------------+
| Environment                              | Callbacks                 |
+--------+---------------------------------+---------+-----------------+
| .z.a   | IP address                      | .z.bm   | msg validator   |
| .z.b   | view dependencies               | .z.exit | action on exit  |
| .z.c   | cores                           | .z.pc   | close           |
| .z.f   | file                            | .z.pd   | peach handles   |
| .z.h   | host                            | .z.pg   | get             |
| .z.i   | PID                             | .z.pi   | input           |
| .z.K   | version                         | .z.po   | open            |
| .z.k   | release date                    | .z.pq   | qcon            |
| .z.l   | license                         | .z.r    | blocked         |
| .z.o   | OS version                      | .z.ps   | set             |
| .z.q   | quiet mode                      | .z.pw   | validate user   |
| .z.s   | self                            | .z.ts   | timer           |
| .z.u   | user ID                         | .z.vs   | value set       |
| .z.X/x | raw/parsed command line         |         |                 |
+--------+---------------------------------+---------+-----------------+
| Environment (Compression/Encryption)     | Callbacks (HTTP)          |
+--------+---------------------------------+---------+-----------------+
| .z.zd  | compression/encryption defaults | .z.ac   | HTTP auth       |
+--------+---------------------------------+ .z.ph   | HTTP get        |
| Environment (Connections)                | .z.pm   | HTTP methods    |
+--------+---------------------------------+ .z.pp   | HTTP post       |
| .z.e   | TLS connection status           |         |                 |
| .z.H   | active sockets                  |         |                 |
| .z.W/w | handles/handle                  |         |                 |
+--------+---------------------------------+---------+-----------------+
| Environment (Debug)                      | Callbacks (WebSockets)    |
+--------+---------------------------------+---------+-----------------+
| .z.ex  | failed primitive                | .z.wc   | WebSocket close |
| .z.ey  | arg to failed primitive         | .z.wo   | WebSocket open  |
+--------+---------------------------------+ .z.ws   | WebSockets      |
| Environment (Time/Date)                  |         |                 |
+--------+---------------------------------+         |                 |
| .z.D/d | date shortcuts                  |         |                 |
| .z.N/n | local/UTC timespan              |         |                 |
| .z.P/p | local/UTC timestamp             |         |                 |
| .z.T/t | time shortcuts                  |         |                 |
| .z.Z/z | local/UTC datetime              |         |                 |
+--------+---------------------------------+---------+-----------------+
```
