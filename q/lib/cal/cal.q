/############
/# Calendar #
/############

/ Override defaults
/.cal.todaysIndicator:"><";
/.cal.dayName:`Sun`Moon`Mars`Mercury`Jupiter`Venus`Saturn;
/.cal.mthName:`Ianuarius`Februarius`Martius`Aprilis`Maius`Iunius`Quintilis`Sextilis`September`October`November`December;
/.cal.mthCols:2;
/.cal.mthColsPad:5;

.cal.setDefault:{[name;default;typ;cnt]
    msg:string[name],$[not .util.exists name;
            [lvl:`debug;" not set"];
        not(typ;cnt)~(type;count)@\:get name;
            [lvl:`error;" set must be of type: [",.Q.s1[typ],"] with a count of: [",string[cnt],"]"];
        :(::)];
    .log[lvl]msg,". Defaulting to: [",.Q.s1[get name set default],"]";};
.cal.setDefault[`.cal.todaysIndicator;"[]";10h;2];
.cal.setDefault[`.cal.dayName;`Su`Mo`Tu`We`Th`Fr`Sa;11h;7];
.cal.setDefault[`.cal.mthName;`January`February`March`April`May`June`July`August`September`October`November`December;11h;12];
.cal.setDefault[`.cal.mthCols;4;-7h;1];
.cal.setDefault[`.cal.mthColsPad;4;-7h;1];

.cal.padSides:{if[y<count x;:y#x];rem:y-count x;l:rem div 2;(l#""),x,(rem-l)#""};
.cal.getMonths:{(12 xbar`month$x)+til 12};

.cal.getCalMonth:{[date;showMthWithYear]
    dates:(`date$month)+til`dd$-1+`date$1+month:`month$date;
    leftPad:(-1+first dates)mod 7;
    dayColPads:2|count each string .cal.dayName;
    calDates:enlist[.cal.dayName],6 7#(leftPad#0Nd),dates;
    calDays:{
        dd:" ",'(neg[y]$string@[`dd$;x;x]),'" ";
        -1_1_raze@[dd;where .z.d~'x;{@[x;-1 1+(min;max)@\:where x in .Q.n;:;.cal.todaysIndicator]}]
        }[;dayColPads]each calDates;
    monthName:.cal.mthName -1+`mm$date;
    title:.cal.padSides[" "sv string monthName,$[showMthWithYear;`year$date;()];-2+sum 2+dayColPads];
    enlist[title],calDays};

.cal.print:{[date;showMthWithYear]
    grid:sv[.cal.mthColsPad#""]each'flip each#[0N,.cal.mthCols]@;
    print:{.util.stdout each(x;"")}each;
    date:asc distinct(),`date$date;
    calMonths:grid .cal.getCalMonth[;showMthWithYear]each date;
    print$[showMthWithYear;();enlist .cal.padSides[string`year$first date;count first first calMonths]],calMonths;
    };

/ @param date - sym (`year`yr`yy`y)             - print the current year calendar
/             - sym (`month`mth`mm`m`day`dd`d`) - print the current month calendar
/             - sym (`N)                        - print N month(s) calendar spanning the current month
/             - long (list)                     - print the number year calendar
/             - date (list)                     - print the date(s) month(s) calendar
cal:.cal.cal:{[date]
    error:{.log.error"Illegal argument";};
    / Symbol atom
    if[-11h~typ:type date;
        if[(date:floor date)in`year`yr`yy`y;:.cal.print[.cal.getMonths .z.d;0b]];
        if[date in`month`mth`mm`m`day`dd`d`;:.cal.print[.z.d;1b]];
        if[not null span:"H"$string date;:.cal.print[months;1<count distinct`year$months:(`month$.z.d)+(til span)-span div 2]];
        :error[]];
    date,:();
    / Number(s) to year(s)
    if[all(absTypes:abs type each date)within 5 7;
        date:"D"$("0"^-4$string date),\:".01.01";
        date@:where not null date;
        :{}(.cal.print[;0b].cal.getMonths@)each date];
    / Date(s)
    if[all absTypes within 12 15;:.cal.print[date;1b]];
    error[];
    };
