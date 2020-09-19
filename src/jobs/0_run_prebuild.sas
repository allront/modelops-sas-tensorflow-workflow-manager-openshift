ffilename logfile '/home/sasdemo/SAS_Workflow_OKD_demo/logs/prebuild.log';

proc printto log=logfile;
run;

filename bashpipe pipe "/home/sasdemo/SAS_Workflow_OKD_demo/src/base/0_prebuild.sh";

data _null_;
infile bashpipe;
input;
put _infile_;
run;