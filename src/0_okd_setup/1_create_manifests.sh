# 1_create_manifests.sh
# O_prebuild.sh is a script to convert the "production" docker-compose in kubernetes manifests with Kompose
#
# Variables:
# OKD_NAME=${1:-openshift} # output folder for manifests
# DOCKER_COMPOSE_FILENAME=${2:-docker-compose.prod.yml} # docker compose file name to convert
#
# Steps:
# 1 - Clean openshift directory
# 2 - Execute kompose convert command

# Variables
OKD_NAME=${1:-openshift}
DOCKER_COMPOSE_FILENAME=${2:-docker-compose.prod.yml}
OKD_DIR=${PROJECT_DIR}/${OKD_NAME}
DOCKER_COMPOSE_FILEPATH=${PROJECT_DIR}/${DOCKER_COMPOSE_FILENAME}

# 1 - Clean openshift directory...
echo "$(date '+%x %r') INFO Cleaning Openshift directory..."
if [ -d "${OKD_DIR}" ]; then
  rm -Rf "${OKD_DIR}"
  mkdir -m 777 "${OKD_DIR}"
fi

# 2 - Execute kompose convert command...
echo "$(date '+%x %r') INFO Converting the ${DOCKER_COMPOSE_FILENAME} in K8s manifests..."
cd "${OKD_DIR}"
/home/ec2-user/kompose --provider openshift --file "${DOCKER_COMPOSE_FILEPATH}" -v convert