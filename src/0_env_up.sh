#!/usr/bin/env bash
# O_env_up.sh
# O_env_up.sh is a script for setting all demo variables and spin up the OKD environment from control node
#
# Variables:
# MINISHIFTPATH=${1:-/home/ec2-user/minishift-1.34.2-linux-amd64/} path of the folder with minishift
# REMOTEIP=${2:-10.249.20.186} the ip of remote OKD
# USEROKD=${3:-root}
#
# Steps:
# 1 - Check cluster status
# 2 - Start minishift and set oc cli
#
# Author: Ivan Nardini (ivan.nardini@sas.com)

#Variables
MINISHIFTPATH=${1:-/home/ec2-user/minishift-1.34.2-linux-amd64/}
REMOTEIP=${2:-10.249.20.186}
USEROKD=${3:-root}

# 1 - Check cluster status
echo "$(date '+%x %r') INFO Check cluster status..."
export PATH=$PATH:${MINISHIFTPATH}
STATUS=$(minishift status | head -n 3 | tail -n 1 | cut -d \   -f 3)
echo "$(date '+%x %r') INFO The remote Openshift enviroment is ${STATUS}!"

# 2 - Start minishift
if [ ${STATUS} != "stopped" ]; then

  echo "$(date '+%x %r') INFO Starting the remote Openshift..."
  minishift start --remote-ipaddress ${REMOTEIP} --remote-ssh-user ${USEROKD} --remote-ssh-key /home/ec2-user/.ssh/id_rsa
  # Set oc cli
  echo ""
  echo "--------------------------------------------------------------"
  echo ""
  echo "Please:"
  echo ""
  echo "1. To set oc cli running the following command:"
  echo ""
  echo "minishift oc-env"
  echo ""
  echo "2. Export path as the command suggests"
  echo ""
  echo "3. Run the following command to get info about user and project"
  echo ""
  echo "oc status"
  echo ""
  echo "4. Remember to export the PROJECT_DIR and mnishift paths"
  echo ""
  echo "export PROJECT_DIR=</path/of/project>"
  echo "export export PATH=$PATH:/home/ec2-user/minishift-1.34.2-linux-amd64/"
  echo ""
  echo "---------------------------------------------------------------"

fi





