filename logfile '/home/sasdemo/SAS_Workflow_OKD_demo/logs/deploy.log';

proc printto log=logfile;
run;

%global TagName;

/* Run 2_deploy.sh script */

%let BashScript = "sh /home/sasdemo/SAS_Workflow_OKD_demo/src/base/2_deploy.sh &TagName.";

filename bashpipe pipe &BashScript.;

data _null_;
infile bashpipe;
input;
put _infile_;
run;