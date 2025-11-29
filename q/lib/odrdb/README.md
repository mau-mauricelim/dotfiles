# 💿 On-disk RDB

On-disk RDB with memory-mapped files

## Key Design

1. Splayed tables with memory mapping
    - Data stored on disk as splayed tables (one file per column)
    - Deferred memory mapping (files are mapped and unmapped on demand)
    - Zero-copy reads - data read directly from disk without loading into heap
    - OS handles paging - only active data in RAM
2. Transparent query access
    - Queries remain exactly the same as a in-memory (traditional) RDB
3. Two-tier architecture
    - Buffer tables - small in-memory accumulator
    - Main tables - memory-mapped from disk
    - When buffer fills > flush to disk > reload main table
4. Performance optimizations
    - Sorted attribute on time for fast time-range queries

## Benefits

### Memory Usage

- In-memory RDB: All data in heap memory
- On-disk RDB: Only buffers + OS page cache
- Savings: 80-95% reduction in heap usage for large datasets

### Query Performance

Slightly slower queries (disk I/O), but still fast with memory mapping

Memory-mapped files mean queries feel almost in-memory like because:
- OS caches frequently accessed pages
- Sequential scans very fast
- No serialization/deserialization overhead

## Test results

```q
$ q odrdb.q
2025.11.28D02:30:09.737934435 [INFO]: QINIT SUCCEED. Startup time: 0D00:00:00.061071775
q)\l test/test.q
2025.11.28D02:30:12.270259972 [INFO]: Initializing in-memory RDB
2025.11.28D02:31:00.432428441 [INFO]: Initializing on-disk RDB
2025.11.28D02:31:00.467667343 [SYSTEM]: t 1000
2025.11.28D02:31:48.054283608 [INFO]: Flushing table: [trade]
2025.11.28D02:31:59.833149640 [INFO]: Flushed table: [trade]. 100000000 rows in 0D00:00:11.775139210
2025.11.28D02:31:59.833353158 [INFO]: Flushing table: [quote]
2025.11.28D02:32:16.845023769 [INFO]: Flushed table: [quote]. 100000000 rows in 0D00:00:17.008946494
2025.11.28D02:32:24.785759841 [INFO]:
2025.11.28D02:32:24.785824355 [INFO]: ########################
2025.11.28D02:32:24.785952128 [INFO]: # Showing test results #
2025.11.28D02:32:24.785979661 [INFO]: ########################
2025.11.28D02:32:24.786000481 [INFO]:
2025.11.28D02:32:24.786041729 [INFO]: Memory statistics:
mem   | rdb         odrdb
------| -----------------------
before| 827.1719 KB 961.2812 KB
after | 11.00079 GB 960.3594 KB
2025.11.28D02:32:24.789353914 [INFO]: Table structure:
s1   | rdb                                                 odrdb
-----| -----------------------------------------------------------------------------------------------------
trade| "+`time`sym`price`size`exchange!(2025.11.28D00:0.." "+`time`sym`price`size`exchange!`:tmp/rdb/trade/"
quote| "+`time`sym`bid`ask`bsize`asize!(2025.11.28D00:0.." "+`time`sym`bid`ask`bsize`asize!`:tmp/rdb/quote/"
2025.11.28D02:32:24.796957300 [INFO]: Performance statistics:
time| rdb odrdb
----| ---------
1   | 402 4356
2   | 387 1679
3   | 383 638
4   | 391 619
5   | 379 622
```

```sh
$ du -shcL tmp/rdb/*
4.5G    tmp/rdb/quote
4.0K    tmp/rdb/sym
3.8G    tmp/rdb/trade
8.2G    total

$ tree tmp/rdb
tmp/rdb
├── quote
│   ├── asize
│   ├── ask
│   ├── bid
│   ├── bsize
│   ├── sym
│   └── time
├── trade
│   ├── exchange
│   ├── price
│   ├── size
│   ├── sym
│   └── time
└── sym
```
