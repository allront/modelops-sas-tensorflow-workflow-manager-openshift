# O_build_images.sh
# O_build_images.sh is a script for building images for Openshift
#
# Variables:
# TAG=${1}
# REGISTRY_HOSTNAME=${2:-docker-registry-default.192.168.99.102.nip.io}
# REGISTRY_PORT=${3:-80}
# IMAGESTREAM=${4-sasmlopshmeq/championmodelserver}
# USERNAME=${5:-developer}
# TOKEN=${6:-eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJwdXNoZWQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoicHVzaGVyLXRva2VuLXF2NnJjIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InB1c2hlciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjdlNmQ3MjY2LWVjMzktMTFlYS1hMmVlLTA4MDAyNzBlNzg3NSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpwdXNoZWQ6cHVzaGVyIn0.e1g919PkYCRVbwykw8AfIcGTvib2VFgGd55kZs8md4uHFe1XsJERMt0XTMpyOU05ZE10gERPY8one01X_NUufS7bZ080zxItqEhnVd64XI6MHlKmZytnsvisVw7Pj3guA0s982pHpQnjVIb6JMdzGpHGVj_YgT4Wr1IJ8oMmW-aHgcI3NbcFwyJ1dDQy7eIqGdcUW7oYz48gR5xBluDfr0aJeoZTX7Kc-XAmPk5Qd94LI2Ky5q1D4Sryo15SdNJ7Vc6mdhS0uXU3CQnAqiY0OoWz1L-LDfX_SOlmqW-G6y3no7iGmARNPO2LZu8zl-E3Bxt_YtJa_sG18WS2CQ-ZeQ}
# IMAGEID=${7:-ba0f4cf619cc}
#
# Steps:
# 0 - Login in the Openshift Registry based on hostname, port, username and token
# For each image:
#   1 - Build docker images
#   2 - Tag docker images
#   3 - Push docker images
#
# Author: Ivan Nardini (ivan.nardini@sas.com)

# Variables
TAG=${1-1.0.0}
REGISTRY_HOSTNAME=${2:-docker-registry-default.10.249.20.186.nip.io}
REGISTRY_PORT=${3:-80}
USERNAME=${4:-developer}
TOKEN=${5:-eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJzYXNtbG9wc2htZXEiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoicHVzaC10b2tlbi1tYjVrZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJwdXNoIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNTE5NWM1MWEtMTEwNS0xMWViLTg2NTItMGE5MzlkZjRkZjA1Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OnNhc21sb3BzaG1lcTpwdXNoIn0.OFnj_Rwe_4BF0Haf3Ymb7K3b14RcGbUUEBFHDNc2RGPxoa6OHZMBXxBH_if6a0fhw0agBUShzf9VBY8KB2dCvfiGtnKom8NgIpaGxq-Vq_0Jr6cIFiZKLmLRgL1RHulg8afIxmRwxXaEj4UrwaTWQr9AZAQb_Lc6xIdShvSR4XPuEuu6VsrP4Um306udllflk3SnGjIExPShCAobv5IxKi1v-4nrtzp2F6k_Ac3SKr2E0IkOLqk0tH-DM9YDKL9mCWxHPg8jzwyq3tBAyd2FQFP25AS3ULhm1qYN1CO4mhk2WKihjYT6NeQBA0YO__nWHAihdcrxEtey07IRwEXBPA}

REGISTRY_HOST=$REGISTRY_HOSTNAME:$REGISTRY_PORT

SCORE_APP_IMAGE_NAME=scoreapp
SCORE_APP_TAG=${SCORE_APP_IMAGE_NAME}:${TAG}
SCORE_APP_IMAGESTREAM=sasmlopshmeq/${SCORE_APP_IMAGE_NAME}
SCORE_APP_BUILDPATH=${PROJECT_DIR}/src/2_okd_base/business_app/
SCORE_APP_FULL_QUALIFIED_IMAGE_NAME=$REGISTRY_HOST/$SCORE_APP_IMAGESTREAM:$TAG

LOGGER_IMAGE_NAME=logger
LOGGER_TAG=${LOGGER_IMAGE_NAME}:${TAG}
LOGGER_IMAGESTREAM=sasmlopshmeq/${LOGGER_IMAGE_NAME}
LOGGER_BUILDPATH=${PROJECT_DIR}/src/2_okd_base/logging_agent/
LOGGER_FULL_QUALIFIED_IMAGE_NAME=$REGISTRY_HOST/$LOGGER_IMAGESTREAM:$TAG

# 0 - Login in the Openshift Registry based on hostname, port, username and token
echo "$(date '+%x %r') INFO Login in the Openshift Registry"
echo "$(date '+%x %r') INFO Openshift Docker registry: $REGISTRY_HOST"
docker login "$REGISTRY_HOST" -u "$USERNAME" -p "$TOKEN"

# For each image:
#   1 - Build docker images
#   2 - Tag docker images
#   3 - Push docker images

echo ""
echo "$(date '+%x %r') INFO Initiating process to ${SCORE_APP_IMAGE_NAME} image..."
echo ""
echo "$(date '+%x %r') INFO Build ${SCORE_APP_IMAGE_NAME} image..."
echo ""
docker build -t "${SCORE_APP_TAG}" "$SCORE_APP_BUILDPATH"
echo ""
echo "$(date '+%x %r') INFO Tag ${SCORE_APP_IMAGE_NAME} image..."
echo ""
docker tag "${SCORE_APP_TAG}" "${SCORE_APP_FULL_QUALIFIED_IMAGE_NAME}"
echo ""
echo "$(date '+%x %r') INFO Push ${SCORE_APP_IMAGE_NAME} image..."
echo ""
docker push "${SCORE_APP_FULL_QUALIFIED_IMAGE_NAME}"

echo ""
echo ""
echo "$(date '+%x %r') INFO Initiating process to ${LOGGER_IMAGE_NAME} image..."
echo ""
echo "$(date '+%x %r') INFO Build ${LOGGER_IMAGE_NAME} image..."
echo ""
docker build -t  "${LOGGER_TAG}" "$LOGGER_BUILDPATH"
echo ""
echo "$(date '+%x %r') INFO Tag ${LOGGER_IMAGE_NAME} image..."
echo ""
docker tag "${LOGGER_TAG}" "${LOGGER_FULL_QUALIFIED_IMAGE_NAME}"
echo ""
echo "$(date '+%x %r') INFO Push ${LOGGER_IMAGE_NAME} image..."
echo ""
docker push "${LOGGER_FULL_QUALIFIED_IMAGE_NAME}"
