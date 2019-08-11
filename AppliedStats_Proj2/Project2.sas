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
if (shot_zone_range = 'Less Than 8 ft.') then szone=0;
if (shot_zone_range = '8-16 ft.') then szone=1;
if (shot_zone_range = '16-24 ft.') then szone=2;
if (shot_zone_range = '24+ ft.') then szone=3;
if (shot_zone_range = 'Back Court Shot') then szone=4;
;



proc logistic data=kobeshot plots=effect;
model shot_made_flag(effect='1')=szone ;
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
*%web_drop_table(tmp_kobedata);




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

proc print data=results(obs=10);
run;

data pred_data;
set results;
keep recId i_shot_made_flag;
run;

proc export data=pred_data
   outfile='/home/pradeep17j0/PradeepFolder/Data/proj2_pred.csv'
   dbms=csv
   replace;
run;


/* for distance vs shot made */
ods graphics on;
proc logistic data=training plots=all plots=oddsratio ;
   class shot_made_flag  playoffs  combined_shot_type shot_zone_range(ref='Less Than 8 ft.') 
   action_type opponent matchup / param=reference;
   model shot_made_flag(event='1') =  shot_zone_range playoffs playoffs*shot_zone_range
   / selection=STEPWISE cl expb lackfit ctable  details ;
   score data=testing  fitstat  ;
   score data=testkobeshot out=results;
run;

proc logistic data=kobeshot plots(only)=effect plots=all;
   class shot_made_flag  playoffs  combined_shot_type shot_zone_range(ref='Less Than 8 ft.') 
   action_type opponent matchup szone / param=reference;
   model shot_made_flag(event='1') =  szone playoffs*szone
   / selection=STEPWISE cl expb lackfit ctable  ;
   score data=testing  fitstat  ;
   *score data=testkobeshot out=results;
run;


proc glmmod data=kobeshot outdesign=GLMDesign outparm=GLMParm NOPRINT;
   class playoffs combined_shot_type shot_zone_range;
   model shot_made_flag = playoffs shot_zone_range ;
run;
 
proc print data=GLMDesign(obs=100); run;
proc print data=GLMParm(obs=100); run;


/*
 proc reg data=GLMDesign;
   DummyVars: model Cholesterol = COL2-COL6; /* dummy variables except intercept */
   ods select ParameterEstimates;

*/


title 'KobeShot Linear Discriminant Function';

proc discrim data=kobeshot pool=yes crossvalidate
  testdata=testkobeshot testout=dataout crosslisterr posterr ;
 class shot_made_flag;
 var shot_distance ;

 run;

title 'KobeShot Linear Discriminant Function End';

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

