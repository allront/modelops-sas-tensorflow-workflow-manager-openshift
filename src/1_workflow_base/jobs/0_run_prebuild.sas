/*********************************************
*************** Prebuild Job *****************
**********************************************
Program Name : 0_run_prebuild.sas
Owner : ivnard/artglz that developed this code
Program Description : Runs Python script for
downloading model from Model Manager to server.

**********************************************
**********************************************
**********************************************/

filename logfile '/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/logs/0_prebuild.log';

proc printto log=logfile;
run;

%global ProjectName;

*For testing;
%let ProjectName = 'SAS ModelOps Tensorflow Openshift';
%put &ProjectName.;

filename bashpipe pipe "/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/src/1_workflow_base/0_prebuild.sh &ProjectName.";

data _null_;
infile bashpipe;
input;
put _infile_;
run;


