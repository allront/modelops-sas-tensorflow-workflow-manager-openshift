filename logfile '/opt/demos/sas_workflow_openshift_demo/logs/3_retrain.log';

proc printto log=logfile;
run;

filename bashpipe pipe "/opt/demos/sas_workflow_openshift_demo/src/base/3_retrain.sh";

data _null_;
infile bashpipe;
input;
put _infile_;
run;
