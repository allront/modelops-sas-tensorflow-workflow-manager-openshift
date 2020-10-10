# 2_create_image_streams.sh
# 2_create_image_streams.sh is a script to deploy image streams on OKD
#
# Variables:
# OKD_NAME=${1:-openshift} # output folder for manifests
#
# Steps:
# Create imagestream in a loop

# Variables
OKD_NAME=${1:-openshift}
OKD_DIR=${PROJECT_DIR}/${OKD_NAME}
IMAGESTREAMFILES="${OKD_DIR}/*.imagestream.yaml"

for m in ${IMAGESTREAMFILES}
do
  echo "Processing the ${m} manifest..."
  oc create -f "${m}"
  echo "Image stream of ${m} manifest created!"
done