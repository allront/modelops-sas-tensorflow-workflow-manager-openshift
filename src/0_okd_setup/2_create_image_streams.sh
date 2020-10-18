#!/usr/bin/env bash
# 2_create_image_streams.sh
# 2_create_image_streams.sh is a script to deploy image streams on OKD
#
# Variables:
# OKD_NAME=${1:-openshift} # output folder for manifests
#
# Steps:
# Create imagestream in a loop
#
# Author: Ivan Nardini (ivan.nardini@sas.com)

# Variables
OKD_NAME=${1:-openshift}
OKD_DIR=${PROJECT_DIR}/${OKD_NAME}

echo "$(date '+%x %r') INFO Initiating process to create image streams..."
for m in "${OKD_DIR}"/*imagestream.yaml
do
  echo "Processing the ${m} manifest..."
  oc create -f "${m}"
  echo ""
done
