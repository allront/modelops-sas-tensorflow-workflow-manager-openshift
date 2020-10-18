filename logfile '/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/logs/0_prebuild.log';

proc printto log=logfile;
run;

%global ProjectName;

filename bashpipe pipe "/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/src/base/0_prebuild.sh &ProjectName.";

data _null_;
infile bashpipe;
input;
put _infile_;
run;


