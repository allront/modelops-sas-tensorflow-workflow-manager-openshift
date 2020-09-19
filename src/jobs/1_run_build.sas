filename logfile '/home/sasdemo/SAS_Workflow_OKD_demo/logs/build.log';

proc printto log=logfile;
run;

/* Run 1_build.sh script and fix current datetime to log */

filename bashpipe pipe "/home/sasdemo/SAS_Workflow_OKD_demo/src/base/1_build.sh";

data _null_;
infile bashpipe;
input;
put _infile_;
run;