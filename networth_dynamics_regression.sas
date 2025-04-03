/*数据处理*/
/*import data*/
%let path=D:\L Leng\master of analytics\178724 Applied Econometric Methods\Assignment\A1 sas; 
libname PRAC "&path";

proc import datafile="D:\L Leng\master of analytics\178724 Applied Econometric Methods\Assignment\Assessment1_data.xlsx"
            out=PRAC.ASSESSMENT1_DATA
            dbms=xlsx
            replace;
run;

/* Descriptive Statistics*/
proc means data=PRAC.ASSESSMENT1_DATA chartype mean std min max n vardef=df;
var wealth pd age male white black hispanic otherrace education 
income employed divorce marriage childbirth familydeath missedwork socioeconomic;
run;

/* Draw histograms and normal Q-Q plots to verify normality */
proc univariate data=PRAC.ASSESSMENT1_DATA;
    var wealth socioeconomic;
    histogram wealth socioeconomic /normal ;
    qqplot wealth socioeconomic /normal;
run;

/* Take Arc-hyperbolic sine transformation */
data PRAC.ASSESSMENT1_DATA_ARSINH;
    set PRAC.ASSESSMENT1_DATA;
    ARSINH_wealth = ARSINH(wealth);
    ARSINH_socioeconomic = ARSINH(socioeconomic);
run;

/*计算相关矩阵 correlation matrix*/
proc corr data=PRAC.ASSESSMENT1_DATA_ARSINH pearson nosimple noprob plots=none noprob nomiss;
var ARSINH_wealth pd age male white black hispanic otherrace education 
income employed divorce marriage childbirth familydeath missedwork ARSINH_socioeconomic;
run;


/*回归分析*/
/*引入wealth和pd进行simple linear regression*/
proc reg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd / white;
run;

/* wealth=pd+income */
proc reg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income / white;
run;

/*wealth=pd+income+education*/
proc reg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education/ white;
run;

/*wealth=pd+income+education+male*/
proc reg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education male/ white;
run;

/*wealth=pd+income+education+male+marrige*/
proc reg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education male marriage/ white;
run;

/*wealth=pd+income+education+male+marrige+pd*male*/
data PRAC.ASSESSMENT1_DATA_ARSINH;
   set PRAC.ASSESSMENT1_DATA_ARSINH;
   pd_male = pd * male;
run;
proc reg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education male marriage pd_male/ white;
run;

/* wealth=pd+income+education+male+marrige+pd*male+pd*marrige */
data PRAC.ASSESSMENT1_DATA_ARSINH;
   set PRAC.ASSESSMENT1_DATA_ARSINH;
   pd_marriage = pd * marriage;
run;
proc reg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education male marriage pd_male pd_marriage/ white;
run;

/* CLRM */
/* Perform white's test on heteroskedasticity */
PROC MODEL;
PARMS B0 B1 B2 B3 B4 B5 B6;
ARSINH_wealth = B0 + B1*pd+B2*income +B3*education +B4*male+ B5*marriage+B6*pd_male;
FIT ARSINH_wealth /WHITE;
RUN;

/* Perform durbin watson test */
proc reg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education male marriage pd_male/dw;
run;

/* Perform breusch godfrey test allowing for 10 lags */
proc autoreg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education male marriage pd_male/godfrey=10;
run;

/*Jarque-Bera Normality test*/
proc autoreg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education male marriage pd_male/NORMAL;
run;

/* Multicollinearity test */
proc corr data=PRAC.ASSESSMENT1_DATA_ARSINH cov plots=matrix;
 var income education male marriage pd_male ;
 with pd;
run;

/* Ramsey’s Reset test */
proc autoreg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education male marriage pd_male/RESET;
run;


proc autoreg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education male marriage pd_male/chow=(210);
run;

proc autoreg data=PRAC.ASSESSMENT1_DATA_ARSINH;
model ARSINH_wealth=pd income education male marriage pd_male/PCHOW=(360 350 200);
run;