#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
trasform_load is an application to read extracted performance data from SAS Viya
and create data for retraining.

Steps:
1- Load performance csv files in pandas Dataframe
2- Append one to another
3- Write on disk the training dataset
"""

import os
import yaml
import pandas as pd
import logging

logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s',
                    datefmt='%m/%d/%Y %I:%M:%S %p',
                    level=logging.INFO)


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


def get_data_list (datapath: str) -> list:
    '''
    Return csv data list
    :param datapath:
    :return: data_paths
    '''
    data_filenames = os.listdir(datapath)
    data_paths = [os.path.join(datapath, filename) for filename in data_filenames]
    return data_paths


def read_data (datapath: str) -> pd.DataFrame:
    '''
    Read csv for creating a nrows Dataframe
    :param datapath:
    :return: data
    '''
    df = pd.read_csv(datapath, sep=',')
    return df


def select_columns (dataframe: pd.DataFrame, labels: list) -> pd.DataFrame:
    '''
    Select columns for retraining
    :param labels:
    :return:
    '''
    df = dataframe[labels]
    return df


def create_training_dataframe (datapaths: list, labels: list) -> pd.DataFrame:
    '''
    Append dataframes one to another
    :param datapaths:
    :return:
    '''
    dfs = [select_columns(read_data(datapath), labels) for datapath in datapaths]
    train_df = pd.concat(dfs)
    return train_df


def write_traindf (train_df: pd.DataFrame, datapath: str):
    '''
    Write training dataframe
    :param train_df:
    :param datapath:
    :return:
    '''

    filename = 'retrain.csv'
    full_datapath = os.path.join(datapath, filename)
    train_df.to_csv(full_datapath, sep=',', index=False)


# Build Process --------------------------------------------------------------------------------------------------------
def build_transform (config):
    DATAMETA = config['data_meta']
    VARIABLE_META_DATA = config['variables_schema_meta']

    def transform ():
        datalist = get_data_list(DATAMETA['datapath_in'])
        train_df = create_training_dataframe(datalist, VARIABLE_META_DATA['labels'])
        return train_df

    return transform


def build_load (config):
    DATAMETA = config['data_meta']

    def load (train_df: pd.DataFrame):
        write_traindf(train_df, DATAMETA['datapath_out'])

    return load

# Main -----------------------------------------------------------------------------------------------------------------
def main ():
    # Read configuration ----------------------------------------
    logging.info('Loading configuration file...')
    CONFIGPATH = './config.yaml'
    CONFIG = load_yaml(CONFIGPATH)

    # Build methods ---------------------------------------------
    logging.info('Building methods...')
    transform = build_transform(CONFIG)
    load = build_load(CONFIG)

    # Run the process --------------------------------------------
    logging.info('Transforming performance data for retraining...')
    train_df = transform()

    # Write retrain file -----------------------------------------
    logging.info('Creating retrain file...')
    load(train_df)
    logging.info('Retrain file created!')


if __name__ == '__main__':
    main()
