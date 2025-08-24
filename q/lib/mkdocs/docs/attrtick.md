# Attributes in the KDB-Tick Stack

```txt
https://www.defconq.tech/docs/concepts/attributes#attributes-in-the-kdb-tick-stack

Tickerplant (TP) attributes
- sorted attribute to the time column
- grouped attribute to the sym column
- subscribers (RDB/RTS) will inherit the same attributes

Historical Database (HDB) attributes
- On-disk data is sorted with parted attribute applied to the sym column
```
