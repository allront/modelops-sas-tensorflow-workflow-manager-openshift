#!/usr/bin/env bash
# O_env_down.sh
# O_env_down.sh is a script for delete all resources and stop the minishift
#
# Variables:
# PROJECTNAME=${1:sasmlopshmeq} path of the folder with minishift
#
# Steps:
# 1 - Delete project
# 2 - Stop minishift

#Variables
PROJECTNAME=${1:sasmlopshmeq}

# 1 - Delete project
echo "$(date '+%x %r') INFO Deleting OKD ${PROJECTNAME} project..."
oc delete project ${PROJECTNAME}

# 2 - Stop minishift
echo "$(date '+%x %r') INFO Stop minishift..."
minishift stop
