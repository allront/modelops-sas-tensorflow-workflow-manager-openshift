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

def split_raw_train_test (raw_df: pd.DataFrame, test_size:float, random_state:int) -> tuple:
    '''
    Given raw data path and data directory, split the raw data
    in train and test
    :param raw_data_path:
    :return: dataframes
    '''
    train, test = train_test_split(raw_df, test_size=test_size, random_state=random_state)
    return train, test

## Preprocessing data

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

## Modelling

def get_dataset (dataframe: pd.DataFrame, target: str, num_epochs=2, mode='eval', batch_size=5):
    '''
    Return input_fn function for TF data ingestion pipeline
    :param dataframe:
    :param target:
    :param num_epochs:
    :param mode:
    :param batch_size:
    :return: input_fn()
    '''

    def input_fn ():
        '''
        Extract data from pd.DataFrame, Impute and enhance data, Load data in parallel
        :return:
        '''

        # Extract
        df = _set_categorical_type(dataframe)
        df = _set_categorical_empty(df)
        df = _set_numerical_type(df)
        predictors = dict(df)
        label = predictors.pop(target)
        dataset = tf.data.Dataset.from_tensor_slices((predictors, label))

        # Transform
        dataset = dataset.map(_impute_missing_categorical)
        dataset = dataset.map(_impute_missing_numerical)

        if mode == 'train':
            dataset = dataset.repeat(num_epochs)  # repeat the original dataset 3 times
            dataset = dataset.shuffle(buffer_size=1000, seed=8)  # shuffle with a buffer of 1000 element

        dataset = dataset.batch(5, drop_remainder=False)  # small batch size to print result

        # Load
        dataset = dataset.prefetch(1)  # It optimize training parallelizing batch loading over CPU and GPU

        return dataset

    return input_fn

def get_features(dataframe: pd.DataFrame, num_features: list, cat_features: list, labels_dict: dict) -> list:
    '''
    Return a list of tf feature columns
    :param num_features:
    :param cat_features:
    :param labels_dict:
    :return: feature_columns
    '''

    data_train = dataframe.copy()
    # Create an empty list for feature
    feature_columns = []

    # Get numerical features
    normalize_parameters = _get_normalization_parameters(num_features)
    for col_name in num_features:
        mean = normalize_parameters[col_name]['mean']
        std = normalize_parameters[col_name]['std']
        normalizer_fn = functools.partial(normalizer, mean=mean, std=std)
        num_feature = tf.feature_column.numeric_column(col_name, dtype=tf.float32, normalizer_fn=normalizer_fn)
        feature_columns.append(num_feature)

    # Get categorical features
    for col_name in cat_features:
        cat_feature = tf.feature_column.categorical_column_with_vocabulary_list(col_name, labels_dict[col_name])
        indicator_column = tf.feature_column.indicator_column(cat_feature)
        feature_columns.append(indicator_column)

    return feature_columns

def build_estimator (feature_columns, learning_rate=0.1):
    '''
    Given feature columns,
    build a LinearClassifier Estimator
    :param feature_columns:
    :param learning_rate:
    :return:
    '''
    feature_layer = tf.keras.layers.DenseFeatures(feature_columns, dtype='float32')

    runconfig = tf.estimator.RunConfig(tf_random_seed=8)

    linear_classifier_base = tf.estimator.LinearClassifier(
        model_dir=LOGS_DIR,
        feature_columns=feature_columns,
        n_classes=2,
        optimizer=tf.keras.optimizers.SGD(learning_rate=learning_rate),
    )

    return linear_classifier_base

# Build Pipeline -------------------------------------------------------------------------------------------------------
def build_ingest_data(config):
    DATAMETA = config['data_meta']
    FULL_DATAPATH = os.path.join(DATAMETA['datapath_out'], DATAMETA['datafile'])
    def ingest_data(test_size=0.1, random_state=8):
        raw_df = read_data(FULL_DATAPATH)
        data_train, data_test = split_raw_train_test(raw_df, test_size, random_state)
        return data_train, data_test
    return ingest_data

def build_train_evaluate (config):

    VARIABLE_SCHEMA_META=config['variables_schema_meta']
    TARGET = VARIABLE_SCHEMA_META['target']
    CATEGORICAL_VARIABLES = VARIABLE_SCHEMA_META['categorical_predictors']
    NUMERICAL_VARIABLES = VARIABLE_SCHEMA_META['numerical_predictors']
    LABELS_DICT = config['labels_dict']
    LOGS_DIR = config['logs_dir']

    def train_evaluate (data_train, data_test):
        # Get dataset
        train_input_fn = get_dataset(data_train, TARGET, batch_size=500, mode='train')
        test_input_fn = get_dataset(data_test, TARGET, batch_size=500)
        # Get Features
        feature_columns = get_features(data_train, NUMERICAL_VARIABLES, CATEGORICAL_VARIABLES, LABELS_DICT)
        # Clean all
        shutil.rmtree(LOGS_DIR, ignore_errors=True)
        # Get estimator
        estimator = build_estimator(feature_columns, learning_rate=0.1)
        # Train the estimator
        estimator_train = estimator.train(input_fn=train_input_fn)
        # Evaluate
        metrics = estimator_train.evaluate(input_fn=test_input_fn)
        return estimator_train, metrics

    return train_evaluate

# Main -----------------------------------------------------------------------------------------------------------

def main():

    # Read configuration ----------------------------------------
    logging.info('Loading configuration file...')
    CONFIGPATH = './config.yaml'
    CONFIG = load_yaml(CONFIGPATH)

    # Build methods ---------------------------------------------
    logging.info('Building methods...')
    ingest_data = build_ingest_data(CONFIG)
    train_evaluate = build_train_evaluate(CONFIG)

    # Run the process --------------------------------------------
    logging.info('Running the training pipeline...')
    logging.info('Preparing the data...')
    data_train, data_test = ingest_data()
    logging.info('Train the model..')
    model, metrics = train_evaluate(data_train, data_test)


if __name__ == "__main__":
    main()