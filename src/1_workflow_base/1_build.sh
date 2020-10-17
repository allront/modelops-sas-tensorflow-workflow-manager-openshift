#!/usr/bin/env bash
# 1_build.sh
# 1_build.sh builds the image on the local registry
#
# Variables:
# MODEL_NAME=${1:-champion_model.zip} artefact name
#
# Steps:
#   0 - Setup
#       a) rm folder not zip
#       a) unzip model
#       b) clear docker environment
#   1 - Download the TensorFlow Serving Docker image and repo
#   2 - Run a temporary Tensorflow container
#   3 - Copy Model inside temporary Tensorflow container
#   4 - Commit the Champion Tensorflow image (https://docs.docker.com/engine/reference/commandline/commit/)

# Variables
WORKDIR=${PROJECT_DIR}/src/1_workflow_base
MODEL_PATH=$WORKDIR/prebuild/model/
MODEL_NAME=${1:-champion_model.zip}
#MODEL_DIR=$(find $MODEL_PATH -type d ! -name '*.*' | head -n 2 | tail -n 1)
MODEL_DIR=$(find $MODEL_PATH -type d ! -name '*.*' | head -n 1)
CONTAINER_NAME="base_$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)"

# 0 - Setup
# a) unzip model
echo "$(date '+%x %r') INFO Unzip Model Artefact"
unzip -o "${MODEL_PATH}${MODEL_NAME}" -d "${MODEL_PATH}"
rm -f "${MODEL_PATH}${MODEL_NAME}"

#b) clean docker environment
echo "$(date '+%x %r') INFO Clean docker enviroment if needed"
[ -z "$(docker ps | grep 'base' | cut -f 1 | cut -d ' ' -f 1)" ] || {
    container_id=$(docker ps | grep 'base' | cut -f 1 | cut -d ' ' -f 1)
    echo "killing base container id $container_id"
    docker kill $container_id > /dev/null
}

# 1 - Download the TensorFlow Serving Docker image and repo
echo "$(date '+%x %r') INFO Pull the TensorFlow Serving Docker image"
docker pull tensorflow/serving:2.3.0

# 2 - Run a temporary Tensorflow container
echo "$(date '+%x %r') INFO Run a temporary Tensorflow container"
docker run -d --name ${CONTAINER_NAME} tensorflow/serving:2.3.0

# 3 - Copy Model inside temporary Tensorflow container
echo "$(date '+%x %r') INFO Copy Model inside temporary Tensorflow container"
docker cp "${MODEL_DIR}" ${CONTAINER_NAME}:/models/champion_model

# 4 - Commit the Champion Tensorflow image (set MODEL_NAME cause tensorflow serving image needs it)
echo "$(date '+%x %r') INFO Commit the Champion Tensorflow image"
docker commit --change "ENV MODEL_NAME champion_model" ${CONTAINER_NAME} tensorflow/serving/champion_model:1.0.0
