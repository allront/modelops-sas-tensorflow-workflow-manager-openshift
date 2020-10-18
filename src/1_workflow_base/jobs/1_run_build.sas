filename logfile '/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/logs/1_build.log';

proc printto log=logfile;
run;

filename bashpipe pipe "/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/src/base/1_build.sh";

data _null_;
infile bashpipe;
input;
put _infile_;
run;
