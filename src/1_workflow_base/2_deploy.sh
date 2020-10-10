# 1_deploy.sh
# 1_deploy.sh pushes Champion Images to OpenShift remotly
#
# Variables:
# TAG=${1}
# REGISTRY_HOSTNAME=${2:-docker-registry-default.192.168.99.102.nip.io}
# REGISTRY_PORT=${3:-80}
# IMAGESTREAM=${4-pushed/champion_model}
# USERNAME=${5:-developer}
# TOKEN=${6:-eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJwdXNoZWQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoicHVzaGVyLXRva2VuLXF2NnJjIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InB1c2hlciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjdlNmQ3MjY2LWVjMzktMTFlYS1hMmVlLTA4MDAyNzBlNzg3NSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpwdXNoZWQ6cHVzaGVyIn0.e1g919PkYCRVbwykw8AfIcGTvib2VFgGd55kZs8md4uHFe1XsJERMt0XTMpyOU05ZE10gERPY8one01X_NUufS7bZ080zxItqEhnVd64XI6MHlKmZytnsvisVw7Pj3guA0s982pHpQnjVIb6JMdzGpHGVj_YgT4Wr1IJ8oMmW-aHgcI3NbcFwyJ1dDQy7eIqGdcUW7oYz48gR5xBluDfr0aJeoZTX7Kc-XAmPk5Qd94LI2Ky5q1D4Sryo15SdNJ7Vc6mdhS0uXU3CQnAqiY0OoWz1L-LDfX_SOlmqW-G6y3no7iGmARNPO2LZu8zl-E3Bxt_YtJa_sG18WS2CQ-ZeQ}
# IMAGEID=${7:-ba0f4cf619cc}
#
# Steps:
#   0 - Login in the Openshift Registry based on hostname, port, username and token
#   1 - Tag the docker image in the proper way
#   2 - Push the image to Openshift

# Variables
TAG=${1-1.0.0}
REGISTRY_HOSTNAME=${2:-docker-registry-default.10.249.20.186.nip.io}
REGISTRY_PORT=${3:-80}
IMAGESTREAM=${4-sasmlopshmeq/championmodelserver}
USERNAME=${5:-developer}
TOKEN=${6:-eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJzYXNtbG9wc2htZXEiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiaXZuYXJkLXRva2VuLTVxanoyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6Iml2bmFyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjM3MDQ2OTY3LTBhZGMtMTFlYi05MTU2LTBhOTM5ZGY0ZGYwNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpzYXNtbG9wc2htZXE6aXZuYXJkIn0.VHFDkSfgFdb_SXHVATxCEFv--krxwuGfOCXclMbnQRoxvCV4DHxqBZO_cVx01DtAI-5kU-ld1BHV6GQwQ-PG-qpI40Jyp-8qFCOqPYc13qzKsWhbqLG99zdg0x4ESBZ9oGNI6gxEoabrjxwp2WQ3Gv8tiH2eqGLwuolB7iNVFWj9TQyhIicShunqo5FuxwwfrohPW9_FOhmKSOEr4hrAA7TznbWAGfFfPzRWzsueIHsBG7uYGhhdZOLxrPEnXxkCoD_iSAS1m6BxKpxAsEa1qBGi3kz94pGDUqKx8zBcKN2MvLG1Nk_J8pIthLtG6Haih-5lZ0-4MYEejcikTbRdcQ}
IMAGEID=${7:-2340a4c68f75}

REGISTRY_HOST=$REGISTRY_HOSTNAME:$REGISTRY_PORT
FULL_QUALIFIED_IMAGE_NAME=$REGISTRY_HOST/$IMAGESTREAM:$TAG

# 0 - Login in the Openshift Registry based on hostname, port, username and token
echo "$(date '+%x %r') INFO Login in the Openshift Registry"
echo "$(date '+%x %r') INFO Openshift Docker registry: $REGISTRY_HOST"
docker login $REGISTRY_HOST -u $USERNAME -p $TOKEN

# 1 - Tag the docker image in the proper way (<registry>/<project>/<imagestream>:<tag>)
echo "$(date '+%x %r') INFO The docker image id is: $IMAGEID"
echo "$(date '+%x %r') INFO The new fully qualified docker image name: $FULL_QUALIFIED_IMAGE_NAME"
docker tag $IMAGEID $FULL_QUALIFIED_IMAGE_NAME
docker image ls

# 2 - Push the image to Openshift
docker push $FULL_QUALIFIED_IMAGE_NAME
