# -*- coding: utf-8 -*-

"""
register.py is the module for register the champion model on server.
Steps:
#
#
"""

# General
import os
import random
import shutil
import subprocess
import getpass
import yaml
import pprint
import zipfile
import uuid
import logging

# Data
import pandas as pd

# SAS Model Manager
import sasctl
from sasctl import Session
from sasctl.services import model_repository, model_management
import sasctl.pzmm as pzmm

# Settings
logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s',
                    datefmt='%m/%d/%Y %I:%M:%S %p',
                    level=logging.DEBUG)


# Helpers --------------------------------------------------------------------------------------------------------------
def load_yaml (filepath):
    '''
    Given file path, Read yaml file
    :param filepath:
    :return: conn_dict
    '''
    with open(filepath) as file:
        conn_dict = yaml.load(file, Loader=yaml.FullLoader)
    return conn_dict


def write_requirements (folder, filename):
    '''
    Given a folder and the filename,
    create the requirements file.
    :param folder:
    :param filename:
    :return:
    '''
    reqfile_path = os.path.join(folder, filename)
    with open(reqfile_path, "w") as f:
        sterr = subprocess.call(["pip", "freeze"], stdout=f, stderr=-1)
    if sterr == 0:
        print("Requirements file created under ", reqfile_path)
    else:
        print("pip freeze command fails!")

# Build Pipeline -------------------------------------------------------------------------------------------------------
def build_write_metadata(config):
    MODEL_META = config['model_meta']
    CHAMPION_PATH = MODEL_META['champion_path']

    def write_metadata():
        write_requirements(CHAMPION_PATH, 'requirements.txt')

    return write_metadata
# Main -----------------------------------------------------------------------------------------------------------

def main ():
    # Read configuration ----------------------------------------
    logging.info('Loading configuration file...')
    CONFIGPATH = './config.yaml'
    CONFIG = load_yaml(CONFIGPATH)

    # Build pipeline --------------------------------------------
    logging.info('Writing Metadata associated to the model...')
    write_metadata = build_write_metadata(CONFIG)
    write_metadata()

if __name__ == "__main__":
    main()