#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
train is the module for retraining the champion model on server.

Steps:
"""

# General
import os
import functools
import shutil
import datetime
import logging
import yaml

# Analysis
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_curve, confusion_matrix

# Modelling
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, DenseFeatures, Dropout
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.losses import BinaryCrossentropy

logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s',
                    datefmt='%m/%d/%Y %I:%M:%S %p',
                    level=logging.DEBUG)
# Helpers --------------------------------------------------------------------------------------------------------------

## Preprocessing data

def load_yaml (configpath: str) -> dict:
    '''
    Given file path, Read yaml file
    :param configpath:
    :return: conn_dict
    '''
    with open(configpath) as file:
        conn_dict = yaml.load(file, Loader=yaml.FullLoader)
    return conn_dict


def read_data (datapath: str) -> pd.DataFrame:
    '''
    Read csv for creating a nrows Dataframe
    :param datapath:
    :return: data
    '''
    df = pd.read_csv(datapath, sep=',')
    return df

def split_raw_train_test (raw_df: pd.DataFrame, test_size:float, random_state:int) -> tuple:
    '''
    Given raw data path and data directory, split the raw data
    in train and test
    :param raw_data_path:
    :return: dataframes
    '''
    train, test = train_test_split(raw_df, test_size=test_size, random_state=random_state)
    return train, test


# Build Pipeline -------------------------------------------------------------------------------------------------------
def build_data(config):
    DATAMETA = config['data_meta']
    FULL_DATAPATH = os.path.join(DATAMETA['datapath_out'], DATAMETA['datafile'])
    def data(test_size=0.1, random_state=8, debug=False):
        raw_df = read_data(FULL_DATAPATH)
        data_train, data_test = split_raw_train_test(raw_df, test_size, random_state)
        if debug:
            logging.debug("Printing some rows...")
            print(data_train.head(5))
        return data_train, data_test
    return data

# Main -----------------------------------------------------------------------------------------------------------

def main():

    # Read configuration ----------------------------------------
    logging.info('Loading configuration file...')
    CONFIGPATH = './config.yaml'
    CONFIG = load_yaml(CONFIGPATH)

    # Build methods ---------------------------------------------
    logging.info('Building methods...')
    data = build_data(CONFIG)

    # Run the process --------------------------------------------
    logging.info('Running the training pipeline...')
    logging.info('Preparing the data...')
    data_train, data_test = data(debug=True)

    # BASE_DIR_PATH = os.getcwd()
    # DATA_DIR_PATH = os.path.join(BASE_DIR_PATH, '../data')
    #
    # # Model directories
    # LOGS_DIR = os.path.join(BASE_DIR_PATH, '../logs')
    # MODELS_DIR = os.path.join(BASE_DIR_PATH, '../models')

if __name__ == "__main__":
    main()