# The .Q namespace

```txt
https://code.kx.com/q/ref/dotq/#the-q-namespace

The .Q namespace
+------------------------------------+--------------------------------------------+
| General                            | Datatype                                   |
+-----------+------------------------+------------+-------------------------------+
| addmonths |                        | btoa       | b64 encode                    |
| dd        | join symbols           | j10        | encode binhex                 |
| f         | precision format       | j12        | encode base 36                |
| fc        | parallel on cut        | ty         | type                          |
| ff        | append columns         | x10        | decode binhex                 |
| fmt       | precision format       | x12        | decode base 36                |
| ft        | apply simple           +------------+-------------------------------+
| fu        | apply unique           | Database                                   |
| gc        | garbage collect        +------------+-------------------------------+
| gz        | GZip                   | chk        | fill HDB                      |
| id        | sanitize               | dpft dpfts | save table                    |
| qt        | is table               | dpt  dpts  | save table unsorted           |
| res       | keywords               | dsftg      | load process save             |
| s         | plain text             | en         | enumerate varchar cols        |
| s1        | string representation  | ens        | enumerate against domain      |
| sha1      | SHA-1 encode           | fk         | foreign key                   |
| V         | table to dict          | hdpf       | save tables                   |
| v         | value                  | l          | load                          |
| view      | subview                | ld         | load and group                |
|-----------+------------------------| li         | load partitions               |
| Constants                          | lo         | load without                  |
|-----------+------------------------| M          | chunk size                    |
| A a an    | alphabets              | qp         | is partitioned                |
| b6        | bicameral alphanums    | qt         | is table                      |
| n nA      | nums & alphanums       |            |                               |
+-----------+------------------------+------------+-------------------------------+
| Debug/Profile                      | Partitioned database state                 |
+-----------+------------------------+------------+-------------------------------+
| bt        | backtrace              | bv         | build vp                      |
| prf0      | code profiler          | bvi        | build incremental vp          |
| sbt       | string backtrace       | cn         | count partitioned table       |
| trp       | extend trap at         | D          | partitions                    |
| trpd      | extend trap            | ind        | partitioned index             |
| ts        | time and space         | MAP        | maps partitions               |
+-----------+------------------------+ par        | locate partition              |
| Environment                        | PD         | partition locations           |
+-----------+------------------------+ pd         | modified partition locns      |
| K k       | version                | pf         | partition field               |
| w         | memory stats           | pn         | partition counts              |
+-----------+------------------------+ pt         | partitioned tables            |
| Environment (Command-line)         | PV         | partition values              |
+-----------+------------------------+ pv         | modified partition values     |
| def       | command defaults       | qp         | is partitioned                |
| opt       | command parameters     | vp         | missing partitions            |
| x         | non-command parameters |            |                               |
+-----------+------------------------+------------+-------------------------------+
| IPC                                | Segmented database state                   |
+-----------+------------------------+------------+-------------------------------+
| addr      | IP/host as int         | P          | segments                      |
| fps fpn   | pipe streaming         | u          | date based                    |
| fs  fsn   | file streaming         +------------+-------------------------------+
| hg        | HTTP get               | File I/O                                   |
| host      | IP to hostname         +------------+-------------------------------+
| hp        | HTTP post              | Cf         | create empty nested char file |
|           |                        | Xf         | create file                   |
+-----------+------------------------+------------+-------------------------------+
```
