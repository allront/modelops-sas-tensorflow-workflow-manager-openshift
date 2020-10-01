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
TAG=${1-1.0.2}
REGISTRY_HOSTNAME=${2:-docker-registry-default.192.168.99.100.nip.io}
REGISTRY_PORT=${3:-80}
IMAGESTREAM=${4-pushed/champion_model}
USERNAME=${5:-developer}
TOKEN=${6:-eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJwdXNoZWQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoicHVzaGVyLXRva2VuLXpsbGt6Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InB1c2hlciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6Ijg0MTA3OGE1LWVkZjgtMTFlYS05ODYyLTA4MDAyNzcwMTdkYiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpwdXNoZWQ6cHVzaGVyIn0.k99UaWSXLBeLjtRiLEburVRpmL8lEokxh6o68ru8AcEC9kuo4Nc0qA7sKU88VEPRN6clyst0KuJOWfv3oziddZZj9bG5kAIkLathMXA98K3LJ5lWBMhdCnd7Wqj4ZIZmF-qJhflEqBW47ygOL62lTQKfPd-SfulrEO8gJyKxg_XwlLlWZM062wAJ1Sm40bM4VvFJhaXLKFXiogIN1moBFm29IHKfdOZamHwNFPcFEPJYTRBBmntRTWNI6pZ_4qDcO2y7J9NbK7NIDiRnIqjhSGyZ9yOogi15bvXZTnVnTUoGPpVAWb-jQ5vh9WqKuRcqTOdNe2Bq2557DzRO3h7j9Q}
IMAGEID=${7:-238fa92e7020}

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