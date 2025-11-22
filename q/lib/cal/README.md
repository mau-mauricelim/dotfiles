# 📅 cal (Calendar)

## Usage examples

### `.cal.print`

Print calendars. The current date (if it exist) will also be indicated by `.cal.todaysIndicator` in the calendar.

#### Print the current year calendar

```q
q).cal.cal`y / `year`yr`yy`y
q).cal.cal`year$.z.d / .z.p .z.z
                                                        2025

         January                       February                       March                         April
Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa
             1   2   3   4                             1                             1             1   2   3   4   5
 5   6   7   8   9  10  11     2   3   4   5   6   7   8     2   3   4   5   6   7   8     6   7   8   9  10  11  12
12  13  14  15  16  17  18     9  10  11  12  13  14  15     9  10  11  12  13  14  15    13  14  15  16  17  18  19
19  20  21  22  23  24  25    16  17  18  19  20  21  22    16  17  18  19  20  21  22    20  21  22  23  24  25  26
26  27  28  29  30  31        23  24  25  26  27  28        23  24  25  26  27  28  29    27  28  29  30           1
         1   2   3   4   5                         1   2    30  31                         2   3   4   5   6   7   8

           May                           June                          July                         August
Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa
                 1   2   3     1   2   3   4   5   6   7             1   2   3   4   5                         1   2
 4   5   6   7   8   9  10     8   9  10  11  12  13  14     6   7   8   9  10  11  12     3   4   5   6   7   8   9
11  12  13  14  15  16  17    15  16  17  18  19  20  21    13  14  15  16  17  18  19    10  11  12  13  14  15  16
18  19  20  21  22  23  24    22  23  24  25  26  27  28    20  21  22  23  24  25  26    17  18  19  20  21  22  23
25  26  27  28  29  30  31    29  30   1   2   3   4   5    27  28  29  30  31            24  25  26  27  28  29  30
                 1   2   3     6   7   8   9  10  11  12     1   2   3   4   5   6   7    31                       1

        September                      October                       November                      December
Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa
     1   2   3   4   5   6                 1   2   3   4                             1         1   2   3   4   5   6
 7   8   9  10  11  12  13     5   6   7   8   9  10  11     2   3   4   5   6   7   8     7   8   9  10  11  12  13
14  15  16  17  18  19  20    12  13  14  15  16  17  18     9  10  11  12  13  14  15    14  15  16  17  18  19  20
21  22  23  24  25  26  27    19  20  21  22  23  24  25    16  17  18 [19] 20  21  22    21  22  23  24  25  26  27
28  29  30       1   2   3    26  27  28  29  30  31        23  24  25  26  27  28  29    28  29  30  31       1   2
 4   5   6   7   8   9  10             1   2   3   4   5    30                             3   4   5   6   7   8   9
```

#### Print the current month calendar

```q
q).cal.cal`d          / `month`mth`mm`m`day`dd`d`
q).cal.cal`1
q).cal.cal .z.d       / .z.p .z.z
q).cal.cal`month$.z.d / .z.p .z.z
      November 2025
Su  Mo  Tu  We  Th  Fr  Sa
                         1
 2   3   4   5   6   7   8
 9  10  11  12  13  14  15
16  17  18 [19] 20  21  22
23  24  25  26  27  28  29
30
```

#### Print N month(s) calendar spanning the current month

> [!NOTE]
> If the calendar months contains spans more than the current year
> - Each calendar month will be printed with the year
> - The calendar year title will not be printed

```q
q).cal.cal`3
                                         2025

         October                       November                      December
Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa
             1   2   3   4                             1         1   2   3   4   5   6
 5   6   7   8   9  10  11     2   3   4   5   6   7   8     7   8   9  10  11  12  13
12  13  14  15  16  17  18     9  10  11  12  13  14  15    14  15  16  17  18  19  20
19  20  21  22  23  24  25    16  17  18 [19] 20  21  22    21  22  23  24  25  26  27
26  27  28  29  30  31        23  24  25  26  27  28  29    28  29  30  31       1   2
         1   2   3   4   5    30                             3   4   5   6   7   8   9

q).cal.cal`6
       August 2025                  September 2025                 October 2025                 November 2025
Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa
                     1   2         1   2   3   4   5   6                 1   2   3   4                             1
 3   4   5   6   7   8   9     7   8   9  10  11  12  13     5   6   7   8   9  10  11     2   3   4   5   6   7   8
10  11  12  13  14  15  16    14  15  16  17  18  19  20    12  13  14  15  16  17  18     9  10  11  12  13  14  15
17  18  19  20  21  22  23    21  22  23  24  25  26  27    19  20  21  22  23  24  25    16  17  18 [19] 20  21  22
24  25  26  27  28  29  30    28  29  30       1   2   3    26  27  28  29  30  31        23  24  25  26  27  28  29
31                       1     4   5   6   7   8   9  10             1   2   3   4   5    30

      December 2025                  January 2026
Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa
     1   2   3   4   5   6                     1   2   3
 7   8   9  10  11  12  13     4   5   6   7   8   9  10
14  15  16  17  18  19  20    11  12  13  14  15  16  17
21  22  23  24  25  26  27    18  19  20  21  22  23  24
28  29  30  31       1   2    25  26  27  28  29  30  31
 3   4   5   6   7   8   9                     1   2   3
```

#### Print the date(s) month(s) calendar

```q
q).cal.cal 2000.01 3000.01m
       January 2000                  January 3000
Su  Mo  Tu  We  Th  Fr  Sa    Su  Mo  Tu  We  Th  Fr  Sa
                         1                 1   2   3   4
 2   3   4   5   6   7   8     5   6   7   8   9  10  11
 9  10  11  12  13  14  15    12  13  14  15  16  17  18
16  17  18  19  20  21  22    19  20  21  22  23  24  25
23  24  25  26  27  28  29    26  27  28  29  30  31
30  31                                 1   2   3   4   5
```

#### Print calendar with custom values

Default values can be adjusted by modifying the following variables

Example:
```q
/ Override defaults
.cal.todaysIndicator:"><";
.cal.dayName:`Sun`Moon`Mars`Mercury`Jupiter`Venus`Saturn;
.cal.mthName:`Ianuarius`Februarius`Martius`Aprilis`Maius`Iunius`Quintilis`Sextilis`September`October`November`December;
.cal.mthCols:2;
.cal.mthColsPad:5;
```

```
q)cal`y
                                                2025

                   Ianuarius                                            Februarius                    <--- Custom month names
Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn     Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn <--- Custom day   names
                       1        2      3       4                                                    1
  5     6     7        8        9     10      11       2     3     4        5        6      7       8
 12    13    14       15       16     17      18       9    10    11       12       13     14      15
 19    20    21       22       23     24      25      16    17    18       19       20     21      22
 26    27    28       29       30     31              23    24    25       26       27     28
              1        2        3      4       5                                            1       2

                    Martius                                              Aprilis
Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn     Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn
                                               1                   1        2        3      4       5
  2     3     4        5        6      7       8       6     7     8        9       10     11      12
  9    10    11       12       13     14      15      13    14    15       16       17     18      19
 16    17    18       19       20     21      22      20    21    22       23       24     25      26
 23    24    25       26       27     28      29      27    28    29       30                       1
 30    31                                              2     3     4        5        6      7       8

                     Maius                                                Iunius
Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn     Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn
                                1      2       3       1     2     3        4        5      6       7
  4     5     6        7        8      9      10       8     9    10       11       12     13      14
 11    12    13       14       15     16      17      15    16    17       18       19     20      21
 18    19    20       21       22     23      24      22    23    24       25       26     27      28
 25    26    27       28       29     30      31      29    30     1        2        3      4       5
                                1      2       3       6     7     8        9       10     11      12

                   Quintilis                                             Sextilis
Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn     Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn
              1        2        3      4       5                                            1       2
  6     7     8        9       10     11      12       3     4     5        6        7      8       9
 13    14    15       16       17     18      19      10    11    12       13       14     15      16
 20    21    22       23       24     25      26      17    18    19       20       21     22      23
 27    28    29       30       31                     24    25    26       27       28     29      30
  1     2     3        4        5      6       7      31                                            1

                   September                                             October
Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn     Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn
        1     2        3        4      5       6                            1        2      3       4
  7     8     9       10       11     12      13       5     6     7        8        9     10      11
 14    15    16       17       18     19      20      12    13    14       15       16     17      18
 21    22    23       24       25     26      27      19    20    21       22       23     24      25
 28    29    30                 1      2       3      26    27    28       29       30     31
  4     5     6        7        8      9      10                   1        2        3      4       5

                    November                                             December
Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn     Sun  Moon  Mars  Mercury  Jupiter  Venus  Saturn
                                               1             1     2        3        4      5       6
  2     3     4        5        6      7       8       7     8     9       10       11     12      13
  9    10    11       12       13     14      15      14    15    16       17       18     19      20
 16    17    18       19       20    >21<     22      21    22    23       24       25     26      27
 23    24    25       26       27     28      29      28    29    30       31               1       2
 30                                                    3     4     5        6        7      8       9

                                     ^  ^ <--- Custom today's indicator

|----------------------------------------------|     |----------------------------------------------| <--- 2 columns of calendar months
                                                ^^^^^                                                 <--- 5 spaces of padding between calendar months
```
