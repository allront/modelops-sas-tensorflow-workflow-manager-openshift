# 1_deploy.sh
# 1_deploy.sh is the script to deploy the application on Openshift
#
# Steps:
# 0 - Clean ImageStreams directory
# 1 - Move Image stream files
# 2 - Apply manifests
#
# Author: Ivan Nardini (ivan.nardini@sas.com)

# Variables
OKD_NAME=${1:-openshift}
OKD_DIR=${PROJECT_DIR}/${OKD_NAME}
IMAGE_STREAMS_DIR="./imagestream"

cd "${OKD_DIR}"

# 0 - Clean ImageStreams directory...
echo "$(date '+%x %r') INFO Cleaning ImageStreams directory..."
if [ -d "${IMAGE_STREAMS_DIR}" ]; then
  sudo rm -Rf "${IMAGE_STREAMS_DIR}"
  mkdir -m 777 "${IMAGE_STREAMS_DIR}"
else
  mkdir -m 777 "${IMAGE_STREAMS_DIR}"
fi

# 1 - Move Image stream files
echo "$(date '+%x %r') INFO Move imagestream manifests in ${IMAGE_STREAMS_DIR} directory..."
mv *imagestream.yaml ${IMAGE_STREAMS_DIR}

# 2 - Apply manifests
echo "$(date '+%x %r') INFO Applying manifests..."
oc apply -f ./
