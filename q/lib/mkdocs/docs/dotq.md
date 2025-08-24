# The .Q namespace

```txt
https://code.kx.com/q/ref/dotq/#the-q-namespace

The .Q namespace
+------------------------------------------+--------------------------------------------------+
| General                                  | Datatype                                         |
+-----------------+------------------------+------------------+-------------------------------+
| .Q.addmonths    | add months             | .Q.btoa          | b64 encode                    |
| .Q.dd           | join symbols           | .Q.j10           | encode binhex                 |
| .Q.f            | precision format       | .Q.j12           | encode base 36                |
| .Q.fc           | parallel on cut        | .Q.ty            | type                          |
| .Q.ff           | append columns         | .Q.x10           | decode binhex                 |
| .Q.fmt          | precision format       | .Q.x12           | decode base 36                |
| .Q.ft           | apply simple           +------------------+-------------------------------+
| .Q.fu           | apply unique           | Database                                         |
| .Q.gc           | garbage collect        +------------------+-------------------------------+
| .Q.gz           | GZip                   | .Q.chk           | fill HDB                      |
| .Q.id           | sanitize               | .Q.dpft .Q.dpfts | save table                    |
| .Q.qt           | is table               | .Q.dpt  .Q.dpts  | save table unsorted           |
| .Q.res          | keywords               | .Q.dsftg         | load process save             |
| .Q.s            | plain text             | .Q.en            | enumerate varchar cols        |
| .Q.s1           | string representation  | .Q.ens           | enumerate against domain      |
| .Q.sha1         | SHA-1 encode           | .Q.fk            | foreign key                   |
| .Q.V            | table to dict          | .Q.hdpf          | save tables                   |
| .Q.v            | value                  | .Q.l             | load                          |
| .Q.view         | subview                | .Q.ld            | load and group                |
+-----------------+------------------------+ .Q.li            | load partitions               |
| Constants                                | .Q.lo            | load without                  |
+-----------------+------------------------+ .Q.M             | chunk size                    |
| .Q.A .Q.a .Q.an | alphabets              | .Q.qp            | is partitioned                |
| .Q.b6           | bicameral alphanums    | .Q.qt            | is table                      |
| .Q.n .Q.nA      | nums & alphanums       |                  |                               |
+-----------------+------------------------+------------------+-------------------------------+
| Debug/Profile                            | Partitioned database state                       |
+-----------------+------------------------+------------------+-------------------------------+
| .Q.bt           | backtrace              | .Q.bv            | build vp                      |
| .Q.prf0         | code profiler          | .Q.bvi           | build incremental vp          |
| .Q.sbt          | string backtrace       | .Q.cn            | count partitioned table       |
| .Q.trp          | extend trap at         | .Q.D             | partitions                    |
| .Q.trpd         | extend trap            | .Q.ind           | partitioned index             |
| .Q.ts           | time and space         | .Q.MAP           | maps partitions               |
+-----------------+------------------------+ .Q.par           | locate partition              |
| Environment                              | .Q.PD            | partition locations           |
+-----------------+------------------------+ .Q.pd            | modified partition locns      |
| .Q.K .Q.k       | version                | .Q.pf            | partition field               |
| .Q.w            | memory stats           | .Q.pn            | partition counts              |
+-----------------+------------------------+ .Q.pt            | partitioned tables            |
| Environment (Command-line)               | .Q.PV            | partition values              |
+-----------------+------------------------+ .Q.pv            | modified partition values     |
| .Q.def          | command defaults       | .Q.qp            | is partitioned                |
| .Q.opt          | command parameters     | .Q.vp            | missing partitions            |
| .Q.x            | non-command parameters |                  |                               |
+-----------------+------------------------+------------------+-------------------------------+
| IPC                                      | Segmented database state                         |
+-----------------+------------------------+------------------+-------------------------------+
| .Q.addr         | IP/host as int         | .Q.P             | segments                      |
| .Q.fps .Q.fpn   | pipe streaming         | .Q.u             | date based                    |
| .Q.fs  .Q.fsn   | file streaming         +------------------+-------------------------------+
| .Q.hg           | HTTP get               | File I/O                                         |
| .Q.host         | IP to hostname         +------------------+-------------------------------+
| .Q.hp           | HTTP post              | .Q.Cf            | create empty nested char file |
|                 |                        | .Q.Xf            | create file                   |
+-----------------+------------------------+------------------+-------------------------------+
```
