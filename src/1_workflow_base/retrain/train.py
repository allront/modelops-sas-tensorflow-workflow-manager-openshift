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
                    level=logging.INFO)
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


def _set_categorical_type (dataframe: pd.DataFrame) -> pd.DataFrame:
    '''
    Set the categorical type as string if neeeded
    :param dataframe:
    :return: dataframe
    '''
    for column in CATEGORICAL_VARIABLES:
        if (dataframe[column].dtype == 'O'):
            dataframe[column] = dataframe[column].astype('string')
    return dataframe


def _set_categorical_empty (dataframe: pd.DataFrame) -> pd.DataFrame:
    '''
    Change object type for categorical variable to avoid TF issue
    :param dataframe:
    :return: dataframe
    '''
    for column in CATEGORICAL_VARIABLES:
        if any(dataframe[column].isna()):
            dataframe[column] = dataframe[column].fillna('')
    return dataframe


def _set_numerical_type (dataframe: pd.DataFrame) -> pd.DataFrame:
    '''
    Set the numerical type as float64 if needed
    :param dataframe:
    :return: dataframe
    '''
    for column in NUMERICAL_VARIABLES:
        if (dataframe[column].dtype == 'int64'):
            dataframe[column] = dataframe[column].astype('float64')
    return dataframe


def _get_impute_parameters_cat (categorical_variables: list) -> dict:
    '''
    For each column in the categorical features, assign default value for missings.
    :param categorical_variables:
    :return: impute_parameters
    '''

    impute_parameters = {}
    for column in categorical_variables:
        impute_parameters[column] = 'Missing'
    return impute_parameters


def _impute_missing_categorical (inputs: dict, target) -> dict:
    '''
    Given a tf.data.Dataset, impute missing in categorical variables with default 'missing' value
    :param inputs:
    :param target:
    :return: output, target
    '''
    impute_parameters = _get_impute_parameters_cat(CATEGORICAL_VARIABLES)
    # Since we modify just some features, we need to start by setting `outputs` to a copy of `inputs.
    output = inputs.copy()
    for key, value in impute_parameters.items():
        is_blank = tf.math.equal('', inputs[key])
        tf_other = tf.constant(value, dtype=np.string_)
        output[key] = tf.where(is_blank, tf_other, inputs[key])
    return output, target


def _get_mean_parameter (dataframe: pd.DataFrame, column: str) -> float:
    '''
    Given a DataFrame column, calculate mean
    :param dataframe:
    :param column:
    :return: mean
    '''
    mean = dataframe[column].mean()
    return mean


def _get_impute_parameters_num (dataframe: pd.DataFrame, numerical_variables: list) -> dict:
    '''
    Given a DataFrame and its numerical variables, return the associated dictionary of means
    :param dataframe:
    :param numerical_variables:
    :return: impute_parameters
    '''

    impute_parameters = {}
    for column in numerical_variables:
        impute_parameters[column] = _get_mean_parameter(dataframe, column)
    return impute_parameters


def _impute_missing_numerical (inputs: dict, target) -> dict:
    '''
    Given a tf.data.Dataset, impute missing in numerical variables with training means
    :param inputs:
    :param target:
    :return: output, target
    '''
    # Get mean parameters for imputing
    impute_parameters = _get_impute_parameters_num(data_train, NUMERICAL_VARIABLES)
    # Since we modify just some features, we need to start by setting `outputs` to a copy of `inputs.
    output = inputs.copy()
    for key, value in impute_parameters.items():
        # Check if nan (true, false mask)
        is_miss = tf.math.is_nan(inputs[key])
        # Store mean in a tf.constant
        tf_mean = tf.constant(value, dtype=np.float64)
        # Impute missing
        output[key] = tf.where(is_miss, tf_mean, inputs[key])
    return output, target


def _get_std_parameter (dataframe: pd.DataFrame, column: str) -> float:
    '''
    Given a DataFrame column, calculate std
    :param dataframe:
    :param column:
    :return: std
    '''
    std = dataframe[column].std()
    return std


def _get_normalization_parameters (numerical_variables: list) -> dict:
    '''
    For each numerical variable, calculate mean and std based on training dataframe
    :param numerical_variables:
    :return: normalize_parameters
    '''
    normalize_parameters = {}
    for column in numerical_variables:
        normalize_parameters[column] = {}
        normalize_parameters[column]['mean'] = _get_mean_parameter(data_train, column)
        normalize_parameters[column]['std'] = _get_std_parameter(data_train, column)
    return normalize_parameters


def normalizer (column, mean, std):
    '''
    Given a column, Normalize with calculated mean and std
    :param column:
    :param mean:
    :param std:
    :return:
    '''
    return (column - mean) / std


def check_feature (feature_column):
    '''
    Given a tf.feature_column and an iter, transform a batch of data
    :param feature_column:
    :return: None
    '''
    feature_layer = keras.layers.DenseFeatures(feature_column)
    print(feature_layer(example_batch).numpy())


def calculate_roc (labels, predictions):
    '''
    Given labels and predictions columns,
    calculare ROC
    :param labels:
    :param predictions:
    :return: fpr, tpr
    '''
    fpr, tpr, _ = roc_curve(labels, predictions)
    return fpr, tpr


def calculate_correlation_matrix (labels, predictions, p=0.5):
    '''
    Given labels and predictions columns,
    calculate confusion matrix for a given p
    :param labels:
    :param predictions:
    :param p:
    :return: corrmat
    '''
    corrmat = confusion_matrix(labels, predictions > p)
    return corrmat


def print_metrics (corrmat, metrics):
    '''
    Show evaluation matrix
    :param corrmat:
    :param metrics:
    :return: None
    '''
    print('Correlation matrix info')
    print('True Negatives - No default loans that pay', corrmat[0][0])
    print('False Positives - No default loans that dont pay', corrmat[0][1])
    print('False Negatives - Default loans that pay', corrmat[1][0])
    print('True Positives: - Default loans that dont pay', corrmat[1][1])
    print('Total Defauts: ', np.sum(corrmat[1]))
    print()
    print('-' * 20)
    print()
    print('Evalutation Metrics')
    for key, value in metrics.items():
        print(key, ':', value)


def setup (folder, modelname):
    '''
    Given root and model name folder,
    remove old version and create a new directory
    :param folder:
    :param modelname:
    :return: model_folder
    '''
    model_folder = os.path.join(folder, modelname)
    # if yes, delete it
    if os.path.exists(model_folder):
        shutil.rmtree(model_folder)
        print("Older ", model_folder, " folder removed!")
    os.makedirs(model_folder)
    print("Directory ", model_folder, " created!")
    return model_folder


def copytree (src, dst, symlinks=False, ignore=None):
    '''
    Given src and dst,
    it copies a directory or a files
    :param src:
    :param dst:
    :param symlinks:
    :param ignore:
    :return: None
    '''
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            shutil.copytree(s, d, symlinks, ignore)
        else:
            shutil.copy2(s, d)

# Build Pipeline -------------------------------------------------------------------------------------------------------
def build_data(config):
    DATAMETA = config['data_meta']

    def data(test_size=0.1, random_state=8, debug=False):
        raw_df = read_data(DATAMETA['datapath_in'])
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
