# 3_retrain.sh
# 3_retrain.sh executes the retraining pipeline in docker images
#
# Variables:
#
# Steps:
#   0 - Transform and Load the performance tables
#   1 - Train the tensorflow model
#   2 - Register the model in SAS Model Manager with a new version

# Variables
WORKDIR=${PROJECT_DIR}/src/1_workflow_base/retrain
#
## TRANSFORM_LOAD variables
#TRANSFORM_LOAD_PATH=${WORKDIR}/0_transform_load/
#TL_IMAGE_NAME=transform_load:1.0.0
#CONTAINER_NAME="tl_$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)"
#DATA_PATH=${TRANSFORM_LOAD_PATH}/data/retrain

## 0 - Transform and Load the performance tables
#
#echo "$(date '+%x %r') INFO Setup transform_load container..."
#docker build -t ${TL_IMAGE_NAME} ${TRANSFORM_LOAD_PATH}
#echo ""
#
#echo "$(date '+%x %r') INFO Clean docker enviroment if needed"
#[ -z "$(docker ps | grep 'tl' | cut -f 1 | cut -d ' ' -f 1)" ] || {
#    container_id=$(docker ps | grep 'tl' | cut -f 1 | cut -d ' ' -f 1)
#    echo "killing tl container id $container_id"
#    docker kill $container_id > /dev/null
#}
#echo ""
#
#echo "$(date '+%x %r') INFO Running the transform_load container..."
#docker container run --name ${CONTAINER_NAME} -v ${DATAPATH}:/transform_load/data ${TL_IMAGE_NAME}
#echo ""

cd ${WORKDIR}
export PYTHONPATH=${PYTHONPATH}:${PROJECT_DIR}/env/lib/python3.7/site-packages/

echo "$(date '+%x %r') INFO Execute transform_load.py"
sudo chmod +x ./transform_load.py
python transform_load.py

echo "$(date '+%x %r') INFO Execute retrain.py"
sudo chmod +x ./retrain.py
python retrain.py

echo "$(date '+%x %r') INFO Execute retrain.py"
sudo chmod +x ./register.py
python register.py


