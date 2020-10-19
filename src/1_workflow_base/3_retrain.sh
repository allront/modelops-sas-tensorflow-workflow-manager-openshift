#!/usr/bin/env bash
# 3_retrain.sh
# 3_retrain.sh executes the retraining pipeline in docker images
#
# Variables:
# WORKDIR=${PROJECT_DIR}/src/1_workflow_base/retrain
# VENV=${PROJECT_DIR}/env/bin/activate
#
# Steps:
#   0 - Transform and Load the performance tables
#   1 - Retrain the tensorflow model
#   2 - Register the model in SAS Model Manager with a new version
#
# Author: Ivan Nardini (ivan.nardini@sas.com)

# Variables
#WORKDIR=${PROJECT_DIR}/src/1_workflow_base/retrain
#VENV=${PROJECT_DIR}/env/bin/activate
# From SAS Viya
WORKDIR=/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/src/1_workflow_base/retrain/
VENV=/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/env/bin/activate


cd ${WORKDIR}
source ${VENV}

#echo "$(date '+%x %r') INFO Execute etl.py"
#sudo chmod +x ./etl.py
#python3 etl.py

echo "$(date '+%x %r') INFO Execute retrain.py"
sudo chmod +x ./train.py
python3 train.py

echo "$(date '+%x %r') INFO Execute register.py"
sudo chmod +x ./register.py
python3 register.py




