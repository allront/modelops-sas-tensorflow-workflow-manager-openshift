# O_prebuild.sh
# O_prebuild.sh is paired with prebuild.py script to download the artefact on the server
#
# Variables:
# CONFIG_FILE=${1:-environment.yaml} configuration path
#
# Steps:
# 1 - Clean target repo
# 2 - Execute python script

# Variables
CONFIG_FILE=${1:-environment.yaml}
OUTFOLDER="/home/sasdemo/SAS_Workflow_OKD_demo/src/base/prebuild/"
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
export PYTHONPATH=${PYTHONPATH}:/home/sasdemo/SAS_Workflow_OKD_demo/env/lib/python3.7/site-packages/
chmod +x ./prebuild.py
python prebuild.py ${CONFIG_FILE}