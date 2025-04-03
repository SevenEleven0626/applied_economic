/* Import Data */
PROC IMPORT DATAFILE="D:\L Leng\master of analytics\178724 Applied Econometric Methods\Assignment\Assignment 2\Assessment2_data_withhead (2).xlsx"
    OUT=work.imported_data
    DBMS=xlsx
    REPLACE;
    GETNAMES=YES;
    DATAROW=2;
RUN;

PROC PRINT DATA=work.imported_data;
RUN;

/* Filter Data */
DATA filtered_data;
    SET work.imported_data;
    WHERE head = 1 AND nofamichange = 1 AND notmoved = 1;
RUN;

PROC PRINT DATA=filtered_data;
RUN;

/* Descriptive Statistics*/
proc means data=filtered_data chartype mean std min max n vardef=df;
var financial_distress wealth pd age male white black hispanic otherrace education 
income employed divorce marriage childbirth familydeath laidoff missedwork studentloan collegedegree socioeconomic;
run;

/* Draw histograms and normal Q-Q plots to verify normality */
proc univariate data=filtered_data;
    var wealth socioeconomic;
    histogram wealth socioeconomic /normal ;
    qqplot wealth socioeconomic /normal;
run;

/* Take Arc-hyperbolic sine transformation */
data filtered_data_ARSINH;
    set filtered_data;
    ARSINH_wealth = ARSINH(wealth);
    ARSINH_socioeconomic = ARSINH(socioeconomic);
run;

/* Step 1: Check for missing values */
proc means data=filtered_data_ARSINH nmiss;
    var ARSINH_wealth pd income education male marriage head nofamichange notmoved;
run;
/* Step 2: Remove observations with missing values */
data filtered_data_ARSINH_clean;
    set filtered_data_ARSINH;
    if nmiss(ARSINH_wealth, pd, income, education, male, marriage, head, nofamichange, notmoved) = 0;
run;

/* Panel Data Regression */
/* FIXED ONE-WAY ESTIMATES ¨C CROSS-SECTIONAL (FIXONE) */
ods graphics on;
proc sort data=filtered_data_ARSINH_clean;
    by id year;
run;

proc panel data=filtered_data_ARSINH_clean;
    id id year;
    model ARSINH_wealth = pd income education male marriage head nofamichange notmoved / fixone;
run;

/* ONE-WAY FIXED EFFECTS - TIME (FIXONETIME) */
proc panel data=filtered_data_ARSINH_clean;
id id year ;
model ARSINH_wealth = pd income education male marriage head nofamichange notmoved / fixonetime ;
run;

/* TWO WAY FIXED EFFECTS (FIXTWO) */
proc panel data=filtered_data_ARSINH_clean;
id id year ;
model ARSINH_wealth = pd income education male marriage head nofamichange notmoved / fixtwo ;
run;

/* RANDOM EFFECTS MODELS */
/* ONE WAY RANDOM EFFECTS (RANONE) */
proc panel data=filtered_data_ARSINH_clean;
id id year ;
model ARSINH_wealth = pd income education male marriage head nofamichange notmoved / ranone ;
run;

/* TWO WAY RANDOM EFFECTS (RANTWO) */
proc panel data=filtered_data_ARSINH_clean;
id id year ;
model ARSINH_wealth = pd income education male marriage head nofamichange notmoved / rantwo ;
run;
