#!/usr/bin/env bash
# O_prebuild.sh
# O_prebuild.sh is paired with prebuild.py script to download the artefact on the server
#
# Variables:
# PROJECT_NAME=${1:-sas_modelops_tensorflow_openshift} SAS Model Manager project name
#
# Steps:
# 1 - Clean target repo
# 2 - Execute python script

# Variables
PROJECT_NAME=${1:-SAS ModelOps Tensorflow Openshift}
CONFIG_FILE="config.yaml"
# From server
#WORKDIR=${PROJECT_DIR}/src/1_workflow_base/prebuild/
#VENV=${PROJECT_DIR}/env/bin/activate
# From SAS Viya
WORKDIR=/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/src/1_workflow_base/prebuild/
VENV=/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/env/bin/activate

MODEL_DIR="./model"

# 1 - Clean target repo
echo "$(date '+%x %r') INFO Setup Model Folder..."
cd "$WORKDIR"
if [ -d "${MODEL_DIR}" ]; then
  rm -Rf "${MODEL_DIR}"
  mkdir -m 777 "${MODEL_DIR}"
fi

# 2 - Execute python script
echo "$(date '+%x %r') INFO Execute prebuild.py"
source ${VENV}
sudo chmod +x ./prebuild.py
python prebuild.py "${PROJECT_NAME}" ${CONFIG_FILE}


