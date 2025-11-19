/        November 2025           / This should be centered, also need an argument to include year
/          November
/ S  Mon  Tue  Wed  Thur  Fr  Sa
/                              1
/ 2    3    4    5     6   7   8
/ 9   10   11   12    13  14  15
/16   17   18 [ 19]   20  21  22
/23   24   25   26    27  28  29
/30

.cal.todaysIndicator:"[]";
.cal.dayNames:`S`Mon`Tue`Wed`Thur`Fr`Sa;

.cal.todaysIndicator:2#.cal.todaysIndicator;
.cal.dayNames:7#.cal.dayNames;
/ Min of 2 space for day number
dayPads:2|count each dayStrs:string .cal.dayNames;

date:.z.d / Input argument

dates:(`date$mth)+til`dd$-1+`date$1+mth:`month$date;
lPad:(-1+first dates)mod 7;
calDates:enlist[.cal.dayNames],6 7#(lPad#0Nd),dates;
calDays:{
    dd:" ",'(neg[x]$string@[`dd$;y;y]),'" ";
    raze@[dd;where .z.d~'y;{x[0],(-1_1_y),x 1}.cal.todaysIndicator] / Use tdyIdc
    }[dayPads]'[calDates];

// TODO: 

