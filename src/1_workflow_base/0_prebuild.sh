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
PROJECT_NAME=${1:-sas_modelops_tensorflow_openshift}
CONFIG_FILE="environment.yaml"
OUTFOLDER="/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/src/base/prebuild/"
MODEL_DIR="/model"


# 1 - Clean target repo
echo "$(date '+%x %r') INFO Setup"
cd $OUTFOLDER
if [ -d "$MODEL_DIR" ]; then
  rm -Rf MODEL_DIR
  mkdir MODEL_DIR
fi

# 2 - Execute python script
echo "$(date '+%x %r') INFO Execute prebuild.py"
export PYTHONPATH=${PYTHONPATH}:/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/env/lib/python3.7/site-packages/
#chmod +x ./prebuild.py
python prebuild.py ${PROJECT_NAME} ${CONFIG_FILE}
