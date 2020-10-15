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


def read_data_nrows (datapath: str, nrows) -> pd.DataFrame:
    '''
    Read csv for creating a nrows Dataframe
    :param datapath:
    :return: data
    '''
    df = pd.read_csv(datapath, sep=',', nrows=nrows)
    return df


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


def get_output_variables (names, labels, eventprob):
    '''
    Given variable names, labels and event probability,
    it creates dataframes for pzmm metadata generation
    :param names:
    :param labels:
    :param eventprob:
    :return: outputVar
    '''
    outputVar = pd.DataFrame(columns=names)
    outputVar[names[0]] = [random.random(), random.random()]
    outputVar[names[1]] = [random.random(), random.random()]
    outputVar[names[2]] = labels
    outputVar[names[3]] = eventprob
    return outputVar


def zip_folder (folder_to_zip_path, rmtree=False):
    '''
    Given the folder to zip path,
    create an archive
    :param folder_to_zip_path:
    :param rmtree:
    :return: zipath
    '''
    path_sep = '/'
    root_dir = path_sep.join(folder_to_zip_path.split('/')[:-1])
    base_dir = folder_to_zip_path.split('/')[-1]
    zipath = shutil.make_archive(
        folder_to_zip_path,  # folder to zip
        'zip',  # the archive format - or tar, bztar, gztar
        root_dir=root_dir,  # folder to zip root
        base_dir=base_dir)  # folder to zip name
    if rmtree:
        shutil.rmtree(folder_to_zip_path)  # remove .zip folder
    return zipath


def run_model_tracking (server, user, password, zipath, projectname, modelname):
    '''
       Given server and project params,
    create a project and register the model in SAS Model manager
    :param server:
    :param user:
    :param password:
    :param project:
    :param model:
    :return: None
    '''

    with Session(hostname=server, username=user, password=password, verify_ssl=False):
        project = model_repository.get_project(projectname)

        zipfile = open(zipath, 'rb')

        model_repository.import_model_from_zip(modelname,
                                               project,
                                               file=zipfile
                                               )
        zipfile.close()


# Build Pipeline -------------------------------------------------------------------------------------------------------
def build_write_metadata (config):
    VARIABLES_SCHEMA_META = config['variables_schema_meta']
    TARGET = VARIABLES_SCHEMA_META['target']
    CATEGORICAL_VARIABLES = VARIABLES_SCHEMA_META['categorical_predictors']
    NUMERICAL_VARIABLES = VARIABLES_SCHEMA_META['numerical_predictors']
    PREDICTORS = CATEGORICAL_VARIABLES + NUMERICAL_VARIABLES
    DATAMETA = config['data_meta']
    MODEL_META = config['model_meta']
    CHAMPION_PATH = MODEL_META['champion_path']
    MODEL_REG_META = config['model_registration']['metadata']

    def write_metadata ():
        write_requirements(CHAMPION_PATH, 'requirements.txt')
        data_train = read_data_nrows(os.path.join(DATAMETA['datapath_out'], DATAMETA['datafile']), 10)
        JSONFiles = pzmm.JSONFiles()
        # write input.json
        JSONFiles.writeVarJSON(data_train[PREDICTORS], isInput=True, jPath=CHAMPION_PATH)
        # write output.json
        outputvars = get_output_variables(MODEL_REG_META['outvar_names'], MODEL_REG_META['labels'],
                                          MODEL_REG_META['eventprob'])
        JSONFiles.writeVarJSON(outputvars, isInput=False, jPath=CHAMPION_PATH)
        # write modelproperties.json
        JSONFiles.writeModelPropertiesJSON(modelName=MODEL_REG_META['modelname'],
                                           modelDesc='The retrained classifier for Tensorflow Boosted Trees models',
                                           targetVariable=TARGET,
                                           modelType='Boosted Tree',
                                           modelPredictors=PREDICTORS,
                                           targetEvent=1,
                                           numTargetCategories=1,
                                           eventProbVar='EM_EVENTPROBABILITY',
                                           jPath=CHAMPION_PATH,
                                           modeler='ivnard')
        # Zip TF variables
        TF_SAVEDMODEL_NAME = \
            [file for file in os.listdir(CHAMPION_PATH) if os.path.isdir(os.path.join(CHAMPION_PATH, file))][0]
        TF_SAVEDMODEL_PATH = os.path.join(CHAMPION_PATH, TF_SAVEDMODEL_NAME)
        # Zip TF SavedModel format
        ZIP_TF_SAVEDMODEL_PATH = zip_folder(TF_SAVEDMODEL_PATH, rmtree=True)
        # Zip the entire folder
        ZIP_CHAMPION_FOLDER = zip_folder(CHAMPION_PATH)
        return ZIP_TF_SAVEDMODEL_PATH, ZIP_CHAMPION_FOLDER

    return write_metadata


def build_run_model_tracking (config, zip_champion_path):
    MODEL_REG = config['model_registration']['registration']

    run_model_tracking(MODEL_REG['server'],
                       MODEL_REG['username'],
                       MODEL_REG['password'],
                       zip_champion_path,
                       MODEL_REG['projectname'],
                       MODEL_REG['modelname'])

    return run_model_tracking


# Main -----------------------------------------------------------------------------------------------------------

def main ():
    # Read configuration ----------------------------------------
    logging.info('Loading configuration file...')
    CONFIGPATH = './config.yaml'
    CONFIG = load_yaml(CONFIGPATH)

    # Run Registration Process --------------------------------------------
    logging.info('Writing Metadata associated to the model...')
    write_metadata = build_write_metadata(CONFIG)
    zip_tf_savedmodel, zip_chmp_folder = write_metadata()
    logging.info(
        f'Tf model zipped in {zip_tf_savedmodel} and Model folder for SAS Model Manager zipped in {zip_chmp_folder}')
    logging.info('Registering the model...')
    run_model_tracking = build_run_model_tracking(CONFIG, zip_chmp_folder)
    run_model_tracking()
    logging.info('Registration completed!')

if __name__ == "__main__":
    main()
