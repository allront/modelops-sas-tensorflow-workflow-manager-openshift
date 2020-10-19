/*********************************************
*************** Deploy Job *******************
**********************************************

Program Name : 3_run_retrain.sas
Owner : ivnard/artglz that developed this code
Program Description : Runs shell script for
retrain model.

**********************************************
**********************************************
**********************************************/

filename logfile '/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/logs/3_retrain.log';

proc printto log=logfile;
run;

filename bashpipe pipe "/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/src/1_workflow_base/3_retrain.sh";

data _null_;
infile bashpipe;
input;
put _infile_;
run;