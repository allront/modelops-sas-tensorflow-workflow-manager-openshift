filename logfile '/opt/demos/sas_workflow_openshift_demo/src/base/1_build.log';

proc printto log=logfile;
run;

filename bashpipe pipe "/opt/demos/sas_workflow_openshift_demo/src/base/1_build.sh";

data _null_;
infile bashpipe;
input;
put _infile_;
run;
