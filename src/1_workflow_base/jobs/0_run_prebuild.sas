filename logfile '/opt/demos/sas_workflow_openshift_demo/src/base/0_prebuild.log';

proc printto log=logfile;
run;

filename bashpipe pipe "/opt/demos/sas_workflow_openshift_demo/src/base/0_prebuild.sh";

data _null_;
infile bashpipe;
input;
put _infile_;
run;