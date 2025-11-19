/############
/# Calendar #
/############

.cal.monthNames:`January`February`March`April`May`June`July`August`September`October`November`December;
.cal.dayNames:`Su`Mo`Tu`We`Th`Fr`Sa;
.cal.daysHeader:" ",("  "sv string .cal.dayNames)," ";
.cal.rowsLen:count .cal.daysHeader;
.cal.padSides:{rem:y-count x;l:rem div 2;(l#""),x,(rem-l)#""};

.cal.getCalMonth:{[date;showMonthWithYear]
    allDatesOfMonth:(`date$month)+til`dd$-1+`date$1+month:`month$date;
    leftPad:first[allDatesOfMonth]mod 7;
    daysPad:4;
    allDaysOfMonth:@[daysPad$neg[daysPad-1]$string`dd$allDatesOfMonth;where .z.d=allDatesOfMonth;{"[",(-2$string`dd$.z.d),"]"}];
    calDays:raze each 6 7#(leftPad#pad),allDaysOfMonth,14#pad:enlist daysPad#"";
    monthYearHeader:.cal.padSides[;.cal.rowsLen]" "sv string .cal.monthNames[-1+`mm$date],$[showMonthWithYear;`year$date;`];
    (monthYearHeader;.cal.daysHeader),calDays
    };

.cal.print:{[date;numCols;colSpace;showYearHeader]
    calMonths:.cal.getCalMonth[;not showYearHeader]each(),`date$date;
    colSpace:0|colSpace-2;
    monthsMatrix:(0N,numCols)#calMonths;
    calMonths:{{(y#"")sv x}[;y]each flip x}[;colSpace]each monthsMatrix;
    if[showYearHeader;-1(.cal.padSides[string`year$first date;count first first calMonths];"")];
    -1 raze calMonths;
    };

.cal.i.cal:{[date;numCols;colSpace]
    print:.cal.print[;numCols;colSpace;];
    typ:type date:asc distinct(),date;
    cnt:count date;
    / Date types
    if[typ within 12 15;:print[date;0b]];
    / Number types
    if[typ within 5 7;
        / 4 digit years
        if[all date within 1000 9999;:{}print[;1b]each("M"string[date],\:".01")+\:til 12];
        / Number of months centered around current month
        if[(all date<1000)&cnt=1;:print[(`month$.z.d)+(til num)-(num:first date)div 2;0b]];
        ];
    if[(`y~first date)&cnt=1;:print[("M"$string[`year$.z.d],".01")+til 12;1b]];
    '"Illegal date supplied";
    };

.cal.cal:.cal.i.cal[;5;4];
