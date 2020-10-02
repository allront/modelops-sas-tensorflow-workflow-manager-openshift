
#Declare target without dependecies
.PHONY: help setup

#Define minimum variables
BASEDIR=/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/
VENVNAME=env

#Set default command
.DEFAULT: help
help:
	@echo "Below the instructions to build the environment"
	@echo "-----------------------------------------------"
	@echo "make setup"
	@echo "	Setup the working virtualenv environment"

#Setup target
setup:
	python3 -m venv ${VENVNAME}; \
	source ./${VENVNAME}/bin/activate; \
       	pip install -r requirements.txt; \
