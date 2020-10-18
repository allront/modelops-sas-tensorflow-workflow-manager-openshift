filename logfile '/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/logs/2_deploy.log';

proc printto log=logfile;
run;

%global TagName;

%let TagName = '1.0.0';

%put &TagName.;

%let BashScript = "sh /opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/src/base/2_deploy.sh &TagName.";

filename bashpipe pipe &BashScript.;

data _null_;
infile bashpipe;
input;
put _infile_;
run;
