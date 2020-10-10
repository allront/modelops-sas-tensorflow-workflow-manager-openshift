filename logfile '/opt/demos/sas_workflow_openshift_demo/logs/2_deploy.log';

proc printto log=logfile;
run;

%global TagName;

%let BashScript = "sh /opt/demos/sas_workflow_openshift_demo/src/base/2_deploy.sh &TagName.";

filename bashpipe pipe &BashScript.;

data _null_;
infile bashpipe;
input;
put _infile_;
run;