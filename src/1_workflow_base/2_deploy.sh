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
# TOKEN=${6:-eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJzYXNtbG9wc2htZXEiLCJrddGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiaXZuYXJkLXRva2VuLW5udnQ4Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6Iml2bmFyZCIsImt1YmVybmV0ZXMuaW8ljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjMxZWZhZmY3LTBhZjQtMTFlYi05MTU2LTBhOTM5ZGY0ZGYwNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpzYXNtbG9wc2htZXE6aXZuYXJkIn0.eJf6uiCglBhuItYmSidnlXF47JU2bJMc_XUyAAUTVXplqAlrR_5IMynOKhGgqp7kVqdzojKgKCpYFFClhbkzUW2cpfJ4QQ3PjDPMG4tR6mUXNGk6FedtxETDKp-y1ps-Fv_q9p3klM5MSi6NvnFzwR0WqzctpoFC3rKHXeVd5hOsY8-e6WRXDx7IdQoMkwpScKJy2I8iJye79-4AUnAA_Y3xHfMNrt-0yWXPj6CRUr2UYipc4xo4D6qFc1tQzLYyEkd1iLZqNaV19KC4FUVJLpnl6ipKHJhwBehD5bmuZ8T1O6NJlop93d2eGXBQ8GpDoAKJSNTQ}
# IMAGEID=${7:-ba0f4cf619cc}
#
# Steps:
#   0 - Login in the Openshift Registry based on hostname, port, username and token
#   1 - Tag the docker image in the proper way
#   2 - Push the image to Openshift

# Variables
TAG=${1-1.0.0}
IMAGENAME=${2:-tensorflow/serving/champion_model}
REGISTRY_HOSTNAME=${3:-docker-registry-default.10.249.20.186.nip.io}
REGISTRY_PORT=${4:-80}
IMAGESTREAM=${5-sasmlopshmeq/championmodelserver}
USERNAME=${6:-developer}
TOKEN=${7:-eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJzYXNtbG9wc2htZXEiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiaXZuYXJkLXRva2VuLW5udnQ4Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6Iml2bmFyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjMxZWZhZmY3LTBhZjQtMTFlYi05MTU2LTBhOTM5ZGY0ZGYwNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpzYXNtbG9wc2htZXE6aXZuYXJkIn0.eJf6uiCglBhuIy8KWjGwtYmSidnlXF47JU2bJMc_XUyAAUTVXplqAlrR_5IMynOKhGgqp7kVqdzojKgKCpYFFClhbkzUW2cpfJ4QQ3PjDPMG4tR6mUXNGk6FedtxETDKp-y1ps-Fv_q9p3klM5MSi6NvnFzwR0WqzctpoFC3rKHXeVd5hOsY8-e6WRXDx7IdQoMPtPlMFvkwpScKJy2I8iJye79-4AUnAA_Y3xHfMNrt-0yWXPj6CRUr2UYipc4xo4D6qFc1tQzLYyEkd1iLZqNaV19KC4FUVJLpnl6ipKHJhwBehD5bmuZ8T1O6NJlop93d2eGXBQ8GpDoAKJSNTQ}

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
