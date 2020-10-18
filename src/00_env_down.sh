#!/usr/bin/env bash
# O_env_down.sh
# O_env_down.sh is a script for delete all resources and stop the minishift
#
# Variables:
# PROJECTNAME=${1:sasmlopshmeq} path of the folder with minishift
#
# Steps:
# 0 - Login
# 1 - Delete project
# 2 - Stop minishift
#
# Author: Ivan Nardini (ivan.nardini@sas.com)

#Variables
PROJECTNAME=${1:-sasmlopshmeq}

# 0 - Login
echo "$(date '+%x %r') INFO Login with developer..."
USER=$(oc whoami)
if [ ${USER} != "developer" ]; then
  oc login -u ${USER}
fi

# 1 - Delete project
echo "$(date '+%x %r') INFO Deleting OKD ${PROJECTNAME} project..."
oc delete project ${PROJECTNAME}

# 2 - Stop minishift
echo "$(date '+%x %r') INFO Stop minishift..."
minishift stop
