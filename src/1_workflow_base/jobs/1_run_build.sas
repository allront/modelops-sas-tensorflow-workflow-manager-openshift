/*********************************************
*************** Build Job ********************
**********************************************

Program Name : 1_run_build.sas
Owner : ivnard/artglz that developed this code
Program Description : Runs shell script for
building docker image based on model downloaded
from Model Manager to server.

**********************************************
**********************************************
**********************************************/

filename logfile '/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/logs/1_build.log';

proc printto log=logfile;
run;

filename bashpipe pipe "/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/src/1_workflow_base/1_build.sh";

data _null_;
infile bashpipe;
input;
put _infile_;
run;
