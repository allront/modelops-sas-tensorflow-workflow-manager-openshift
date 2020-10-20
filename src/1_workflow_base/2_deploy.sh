#!/usr/bin/env bash
# 1_deploy.sh
# 1_deploy.sh pushes Champion Images to OpenShift remotly
#
# Variables:
# TAG=${1}
# REGISTRY_HOSTNAME=${2:-docker-registry-default.192.168.99.102.nip.io}
# REGISTRY_PORT=${3:-80}
# IMAGESTREAM=${4-sasmlopshmeq/championmodelserver}
# USERNAME=${5:-developer}
# TOKEN=${6:-eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJzYXNtbG9wc2htZXEiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoicHVzaC10b2tlbi16cGdtdiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJwdXNoIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiOGQxMTcxN2ItMTExZC0xMWViLTg2NTItMGE5MzlkZjRkZjA1Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OnNhc21sb3BzaG1lcTpwdXNoIn0.jdTOKzaPUigzpIGBX1TeWHfvKu-8WSzZZKx34g2JUYEuugpb8BxNxAJVeStUyLzCuyxsF5mPkg1WpJHuwRNNTpq7eDEM_K7IJtyCU3cGhHe5etWZWj0J_4evlAE3U0yxYQ2Q6srIwbwoIPWGbr8AOBsycUkCNl4WGgWkit1c77Nf3FMdQzUFjeKLwlT0wFc5941xPsWoUjIv8aHw5cT-mJxemj6oCYbQd2W2M4GOQPX_QgteMaEv-axBkOvsXLes_gimiTU35TnIUWC1N3TWAOWiaa713CiiJ_KM6dLpCuD4wMQZUagJOsPxpMMX-Sz45Y5ljulyaDs149Of3JEjRQ}
# IMAGEID=${7:-ba0f4cf619cc}
#
# Steps:
#   0 - Login in the Openshift Registry based on hostname, port, username and token
#   1 - Tag the docker image in the proper way
#   2 - Push the image to Openshift
#
# Author: Ivan Nardini (ivan.nardini@sas.com)

# Variables
TAG=${1-1.0.0}
IMAGENAME=${2:-tensorflow/serving/champion_model}
REGISTRY_HOSTNAME=${3:-docker-registry-default.10.249.20.186.nip.io}
REGISTRY_PORT=${4:-80}
IMAGESTREAM=${5-sasmlopshmeq/championmodelserver}
USERNAME=${6:-developer}
TOKEN=${7:-eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJzYXNtbG9wc2htZXEiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoicHVzaC10b2tlbi16cGdtdiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJwdXNoIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiOGQxMTcxN2ItMTExZC0xMWViLTg2NTItMGE5MzlkZjRkZjA1Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OnNhc21sb3BzaG1lcTpwdXNoIn0.jdTOKzaPUigzpIGBX1TeWHfvKu-8WSzZZKx34g2JUYEuugpb8BxNxAJVeStUyLzCuyxsF5mPkg1WpJHuwRNNTpq7eDEM_K7IJtyCU3cGhHe5etWZWj0J_4evlAE3U0yxYQ2Q6srIwbwoIPWGbr8AOBsycUkCNl4WGgWkit1c77Nf3FMdQzUFjeKLwlT0wFc5941xPsWoUjIv8aHw5cT-mJxemj6oCYbQd2W2M4GOQPX_QgteMaEv-axBkOvsXLes_gimiTU35TnIUWC1N3TWAOWiaa713CiiJ_KM6dLpCuD4wMQZUagJOsPxpMMX-Sz45Y5ljulyaDs149Of3JEjRQ}

IMAGENAME_TAG=${IMAGENAME}:${TAG}
REGISTRY_HOST=$REGISTRY_HOSTNAME:$REGISTRY_PORT
FULL_QUALIFIED_IMAGE_NAME=$REGISTRY_HOST/$IMAGESTREAM:$TAG

# 0 - Login in the Openshift Registry based on hostname, port, username and token
echo "$(date '+%x %r') INFO Login in the Openshift Registry"
echo "$(date '+%x %r') INFO Openshift Docker registry: $REGISTRY_HOST"
docker login $REGISTRY_HOST -u $USERNAME -p $TOKEN

# 1 - Tag the docker image in the proper way (<registry>/<project>/<imagestream>:<tag>)
echo "$(date '+%x %r') INFO The docker image tag is: $IMAGENAME_TAG"
echo "$(date '+%x %r') INFO The new fully qualified docker image name: $FULL_QUALIFIED_IMAGE_NAME"
docker tag $IMAGENAME_TAG $FULL_QUALIFIED_IMAGE_NAME
docker image ls

# 2 - Push the image to Openshift
docker push $FULL_QUALIFIED_IMAGE_NAME
