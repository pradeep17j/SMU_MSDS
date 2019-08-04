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


proc print data=kobeshot(obs=10);
run;

proc freq data=kobeshot;
table shot_made_flag shot_distance shot_made_flag*shot_distance / out=p outpct;
run;

proc print data=p(obs=10);
run;

proc sgplot data=p;
scatter x=shot_distance y=pct_col/ group=shot_made_flag;
run;

data logit;
set p;
logit = log(pct_col/100/(1-pct_col/100));
;

proc sgplot data=logit;
by shot_made_flag;
scatter x=shot_distance y=logit/ group=shot_made_flag;
run;


proc logistic data=kobeshot;
model shot_made_flag=shot_distance;
run;
