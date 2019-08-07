/* Generated Code (IMPORT) */
/* Source File: model_KobeData.csv */
/* Source Path: /home/pradeep17j0/PradeepFolder/MSDS6372/Proj2 */
/* Code generated on: 8/2/19, 6:04 PM */

%web_drop_table(kobeshot);


FILENAME REFFILE '/home/pradeep17j0/PradeepFolder/MSDS6372/Proj2/model_KobeData.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=kobeshot;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=kobeshot; RUN;


%web_open_table(kobeshot);


%web_drop_table(testkobeshot);

%web_drop_table(new_data);


FILENAME REFFILE '/home/pradeep17j0/PradeepFolder/MSDS6372/Proj2/test_KobeData.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=testkobeshot;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=testkobeshot; RUN;


%web_open_table(testkobeshot);


proc print data=kobeshot(obs=10);
run;

proc print data=testkobeshot(obs=10);
run;


proc freq data=kobeshot;
table shot_made_flag shot_distance shot_made_flag*shot_distance / out=p outpct;
run;


data kobeshot;
set kobeshot;
if (shot_zone_range = 'Less Than 8 ft.') then szone=0;
if (shot_zone_range ='8-16 ft.') then szone=1;
if (shot_zone_range = '16-24 ft.') then szone=2;
if (shot_zone_range = '24+ ft.') then szone=3;
if (shot_zone_range = 'Back Court Shot') then szone=4;

;

proc freq data=kobeshot;
table shot_made_flag szone shot_made_flag*szone / out=p1 outpct;
run;

proc print data=p(obs=10);
run;

proc sgplot data=p;
scatter x=shot_distance y=pct_col/ group=shot_made_flag;
run;

proc sgplot data=p1;
by shot_made_flag;
scatter x=szone y=pct_col;
run;



data logit;
set p;
logit = log(pct_col/100/(1-pct_col/100));
;

proc sgplot data=logit;
by shot_made_flag;
scatter x=shot_distance y=logit;
run;

/* "16-24 ft."       "24+ ft."         "8-16 ft."        "Back Court Shot" "Less Than 8 ft." */

data kobeshot;
set kobeshot;
if (shot_zone_range == 'Less Than 8 ft.') then szone=0;
if (shot_zone_range == '8-16 ft.') then szone=1;
if (shot_zone_range == '16-24 ft.') then szone=2;
if (shot_zone_range == '24+ ft.') then szone=3;
if (shot_zone_range == 'Back Court Shot') then szone=4;

;



proc logistic data=kobeshot;
model shot_made_flag=shot_distance arena_temp loc_x loc_y ;
run;

data new_data;
set testkobeshot;
*shot_made_flag =.;
;


data combined_data;
set kobeshot new_data;
log_shotdist=log(shot_distance)
;

data tmp_kobedata;
set kobeshot;
n=ranuni(8);
proc sort data=tmp_kobedata;
  by n;
  data training testing;
   set tmp_kobedata nobs=nobs;
   if _n_<=.7*nobs then output training;
    else output testing;
run;
*%web_drop_table(training);
*%web_drop_table(testing);
%web_drop_table(tmp_kobedata);




ods graphics on;
proc logistic data=kobeshot plots(only)=(oddsratio(range=clip)) descending outmodel=Model1 PLOTS(MAXPOINTS=NONE);
   class shot_made_flag  playoffs  combined_shot_type shot_zone_range action_type;
   model shot_made_flag(event='1') = shot_zone_range combined_shot_type playoffs arena_temp action_type
   / selection=STEPWISE cl expb lackfit ctable outroc=troc;
   oddsratio shot_made_flag;
   output out=predicted predicted=l;
   score data=kobeshot outroc=vroc;
   
run;
ods graphics off;

ods graphics on;
proc logistic data=training  descending outmodel=Model1 PLOTS(MAXPOINTS=NONE);
   class shot_made_flag  playoffs  combined_shot_type shot_zone_range action_type;
   model shot_made_flag(event='1') = shot_zone_range combined_shot_type playoffs arena_temp action_type loc_x
   / selection=STEPWISE cl expb lackfit ctable outroc=troc;
   oddsratio shot_made_flag;
   output out=predicted predicted=l;
   score data=testing outroc=vroc fitstat ;
   roc;
   
run;


proc logistic data=training;
   class shot_made_flag  playoffs  combined_shot_type shot_zone_range action_type;
   model shot_made_flag(event='1') = playoffs combined_shot_type shot_zone_range action_type 
   seconds_remaining avgnoisedb seconds_remaining*avgnoisedb
   / selection=STEPWISE cl expb lackfit ctable;
   score data=testing  fitstat ;
run;

/* final model */
proc logistic data=training;
   class shot_made_flag  playoffs(ref='0')  combined_shot_type shot_zone_range(ref='Less Than 8 ft.') 
   action_type opponent matchup / param=reference;
   model shot_made_flag(event='1') = playoffs action_type shot_zone_range
   seconds_remaining avgnoisedb playoffs*shot_zone_range
   / selection=STEPWISE cl expb lackfit ctable outroc=troc stopres pprob=0.45 ;
   score data=testing  fitstat outroc=vroc ;
   score data=testkobeshot out=results;
run;


/* for distance vs shot made */
proc logistic data=training;
   class shot_made_flag  playoffs  combined_shot_type shot_zone_range(ref='Less Than 8 ft.') 
   action_type opponent matchup / param=reference;
   model shot_made_flag(event='1') =  shot_zone_range playoffs*shot_zone_range
   / selection=STEPWISE cl expb lackfit ctable  ;
   score data=testing  fitstat  ;
   score data=testkobeshot out=results;
run;


proc discrim data=kobeshot pool=yes crossvalidate
  testdata=testkobeshot testout=dataout crosslisterr;
 class shot_made_flag;
 var ;
 run;



proc print data=dataout;
run;


ods graphics on;
proc logistic data=training  descending outmodel=Model1 PLOTS(MAXPOINTS=NONE);
   class shot_made_flag  playoffs  combined_shot_type shot_zone_range shot_zone_basic action_type shot_zone_area;
   model shot_made_flag(event='1') = shot_zone_range  combined_shot_type  playoffs  arena_temp action_type shot_zone_basic 
   shot_zone_area
   / selection=STEPWISE cl expb lackfit ctable outroc=troc;
   
   output out=predicted predicted=l;
   score data=testing outroc=vroc;
   
run;

/*
ods graphics on;
proc logistic data=combined_data plots(only)=(oddsratio(range=clip)) descending outmodel=Model1;
   class shot_made_flag (ref='0') playoffs (ref='0') combined_shot_type /param=reference;
   model shot_made_flag= shot_distance | arena_temp | loc_x |loc_y | playoffs |seconds_remaining
   / selection=STEPWISE cl expb lackfit ctable;
   oddsratio shot_made_flag;
   output out=predicted predicted=l;
run;
ods graphics off;

*/

ods graphics on;
proc logistic inmodel=Model1;
score data=combined_data fitstat clm outroc=vroc;
roc;
run;
ods graphics off;

title 'Discriminant Analysis of Remote Sensing Data on Five Crops';

data crops;
   input Crop $ 1-10 x1-x4 xvalues $ 11-21;
   datalines;
Corn      16 27 31 33
Corn      15 23 30 30
Soybeans  24 24 25 32
Soybeans  21 25 23 24
Corn      12 15 16 73
Soybeans  20 23 23 25
Soybeans  24 24 25 32
Soybeans  21 25 23 24
Soybeans  27 45 24 12
Soybeans  12 13 15 42
Soybeans  22 32 31 43
Cotton    31 32 33 34
Cotton    29 24 26 28
Cotton    34 32 28 45
Cotton    26 25 23 24
Cotton    53 48 75 26
Cotton    34 35 25 78
Sugarbeets22 23 25 42
Sugarbeets25 25 24 26
Sugarbeets34 25 16 52
Sugarbeets54 23 21 54
Sugarbeets25 43 32 15
Sugarbeets26 54  2 54
Clover    12 45 32 54
Clover    24 58 25 34
Clover    87 54 61 21
Clover    51 31 31 16
Clover    96 48 54 62
Clover    31 31 11 11
Clover    56 13 13 71
Clover    32 13 27 32
Clover    36 26 54 32
Clover    53 08 06 54
Clover    32 32 62 16

;

title2 'Using the Linear Discriminant Function';

proc discrim data=crops outstat=cropstat method=normal pool=yes
             list crossvalidate crosslisterr listerr;
   class Crop;
   priors prop;
   id xvalues;
   var x1-x4;
run;


data test;
   input Crop $ 1-10 x1-x4 xvalues $ 11-21;
   datalines;
Corn      16 27 31 33
Soybeans  21 25 23 24
Cotton    29 24 26 28
Sugarbeets54 23 21 54
Clover    32 32 62 16
;title2 'Classification of Test Data';

proc discrim data=cropstat testdata=test testout=tout testlist listerr ;
   class Crop;
   testid xvalues;
   var x1-x4;
run;

proc print data=tout;
   title 'Discriminant Analysis of Remote Sensing Data on Five Crops';
   title2 'Output Classification Results of Test Data';
run;



