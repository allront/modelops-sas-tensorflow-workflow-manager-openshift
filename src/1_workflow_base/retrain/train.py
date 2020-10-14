#!/usr/bin/python3
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

# Settings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # FATAL
tf.logging.set_verbosity(tf.logging.FATAL)
logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s',
                    datefmt='%m/%d/%Y %I:%M:%S %p',
                    level=logging.DEBUG)
# Helpers --------------------------------------------------------------------------------------------------------------

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


def split_raw_train_test (raw_df: pd.DataFrame, test_size: float, random_state: int) -> tuple:
    '''
    Given raw data path and data directory, split the raw data
    in train and test
    :param raw_data_path:
    :return: dataframes
    '''
    train, test = train_test_split(raw_df, test_size=test_size, random_state=random_state)
    return train, test

def _set_categorical_type (dataframe: pd.DataFrame, categoricals:list) -> pd.DataFrame:
        '''
        Set the categorical type as string if neeeded
        :param dataframe:
        :return: dataframe
        '''
        for column in categoricals:
            if (dataframe[column].dtype == 'O'):
                dataframe[column] = dataframe[column].astype('string')
        return dataframe


def _set_categorical_empty (dataframe: pd.DataFrame, categoricals:list) -> pd.DataFrame:
    '''
    Change object type for categorical variable to avoid TF issue
    :param dataframe:
    :return: dataframe
    '''
    for column in categoricals:
        if any(dataframe[column].isna()):
            dataframe[column] = dataframe[column].fillna('')
    return dataframe

def _set_numerical_type (dataframe: pd.DataFrame, numericals:list) -> pd.DataFrame:
    '''
    Set the numerical type as float64 if needed
    :param dataframe:
    :return: dataframe
    '''
    for column in numericals:
        if (dataframe[column].dtype == 'int64'):
            dataframe[column] = dataframe[column].astype('float64')
    return dataframe

def _get_impute_parameters_cat(categorical_variables: list) -> dict:
    '''
    For each column in the categorical features, assign default value for missings.
    :param categorical_variables:
    :return: impute_parameters
    '''

    impute_parameters = {}
    for column in categorical_variables:
        impute_parameters[column] = 'Missing'
    return impute_parameters

def _get_mean_parameter(dataframe: pd.DataFrame, column: str) -> float:
    '''
    Given a DataFrame column, calculate mean
    :param dataframe:
    :param column:
    :return: mean
    '''
    mean = dataframe[column].mean()
    return mean

def _get_impute_parameters_num(dataframe: pd.DataFrame, numerical_variables: list) -> dict:
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


# Build Pipeline -------------------------------------------------------------------------------------------------------
def build_ingest_data (config):
    DATAMETA = config['data_meta']
    FULL_DATAPATH = os.path.join(DATAMETA['datapath_out'], DATAMETA['datafile'])

    def ingest_data (test_size=0.1, random_state=8):
        raw_df = read_data(FULL_DATAPATH)
        data_train, data_test = split_raw_train_test(raw_df, test_size, random_state)
        return data_train, data_test

    return ingest_data

def build_imputers(config, data_train):

    VARIABLES_SCHEMA_META = config['variables_schema_meta']
    CATEGORICAL_VARIABLES = VARIABLES_SCHEMA_META['categorical_predictors']
    NUMERICAL_VARIABLES = VARIABLES_SCHEMA_META['numerical_predictors']

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

    return _impute_missing_categorical, _impute_missing_numerical

def build_input_df(config, dataframe, _impute_missing_categorical, _impute_missing_numerical, mode='eval'):

    VARIABLES_SCHEMA_META = config['variables_schema_meta']
    CATEGORICAL_VARIABLES = VARIABLES_SCHEMA_META['categorical_predictors']
    NUMERICAL_VARIABLES = VARIABLES_SCHEMA_META['numerical_predictors']
    TARGET = VARIABLES_SCHEMA_META['target']
    EPOCHS = config['input_meta']['num_epochs']
    BATCH_SIZE = config['input_meta']['batch_size']


    def input_fn ():
        '''
        Extract data from pd.DataFrame, Impute and enhance data, Load data in parallel
        :return:
        '''

        # Extract
        df = _set_categorical_type(dataframe, CATEGORICAL_VARIABLES)
        df = _set_categorical_empty(df, CATEGORICAL_VARIABLES)
        df = _set_numerical_type(df, NUMERICAL_VARIABLES)
        predictors = dict(df)
        label = predictors.pop(TARGET)
        dataset = tf.data.Dataset.from_tensor_slices((predictors, label))

        # Transform
        dataset = dataset.map(_impute_missing_categorical)
        dataset = dataset.map(_impute_missing_numerical)

        if mode == 'train':
            dataset = dataset.repeat(EPOCHS)  # repeat the original dataset 3 times
            dataset = dataset.shuffle(buffer_size=1000, seed=8)  # shuffle with a buffer of 1000 element

        dataset = dataset.batch(BATCH_SIZE, drop_remainder=False)  # small batch size to print result

        # Load
        dataset = dataset.prefetch(1)  # It optimize training parallelizing batch loading over CPU and GPU

        return dataset

    return input_fn

def build_pipeline(config):
    pass


# Main -----------------------------------------------------------------------------------------------------------

def main ():
    # Read configuration ----------------------------------------
    logging.info('Loading configuration file...')
    CONFIGPATH = './config.yaml'
    CONFIG = load_yaml(CONFIGPATH)

    # Build methods and run the process -------------------------
    logging.info('Training pipeline starts...')

    logging.info('Prepare data for training...')
    ingest_data = build_ingest_data(CONFIG)
    data_train, data_test = ingest_data()

    logging.info('Build imputers...')
    _impute_missing_categorical, _impute_missing_numerical = build_imputers(CONFIG, data_train)
    logging.info('Build input_fn...')
    train_input_fn = build_input_df(CONFIG, data_train, _impute_missing_categorical, _impute_missing_numerical, 'train')
    test_input_fn = build_input_df(CONFIG, data_train, _impute_missing_categorical, _impute_missing_numerical)

    for feature_batch, label_batch in train_input_fn().take(1):
        print('Feature keys:', list(feature_batch.keys()))
        print('A batch of REASON:', feature_batch['REASON'].numpy())
        print('A batch of Labels:', label_batch.numpy())

if __name__ == "__main__":
    main()
