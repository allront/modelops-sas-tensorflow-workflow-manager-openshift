#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
load_logs is an dedicated sidecar container for logging in an application.

Steps:
1- Read the log file
2- Split dataframe
2- Push logs directly to a backend from within an application.
Author: Ivan Nardini (ivan.nardini@sas.com)
"""

# Libraries
import yaml
import pandas as pd
import math
import sqlalchemy
from sqlalchemy import create_engine
import os
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


def read_data (datapath: str, nrows=None) -> pd.DataFrame:
    '''
    Read csv for creating a nrows Dataframe
    :param datapath:
    :param nrows:
    :return: data
    '''
    data = pd.read_csv(datapath, sep=',')
    if nrows:
        data = data[:nrows]
    return data


def split_dataframe (df: pd.DataFrame, chunk_size=1000) -> list:
    '''
    :param df:
    :param chunk_size:
    :return: dfs
    '''
    dfs = list()
    num_chunks = math.ceil(len(df) / chunk_size)
    for i in range(num_chunks):
        dfs.append(df[i * chunk_size:(i + 1) * chunk_size])
    return dfs


def create_connection (driver: str, username: str, password: str, hostname: str, port: int,
                       dbname: str) -> sqlalchemy.engine:
    '''
    Create engine based on connection string
    :param driver:
    :param username:
    :param password:
    :param hostname:
    :param port:
    :param dbname:
    :return: engine
    '''
    conn_str = f'{driver}://{username}:{password}@{hostname}:{port}/{dbname}'
    engine = create_engine(conn_str)
    return engine


def set_tablename (prefix: str, sequencenumber: int, timelabel: str) -> str:
    '''
    Define tablename as SAS Model Manager needs for performance
    :param prefix:
    :param sequencenumber:
    :param timelabel:
    :return: tablename
    '''
    fulltimelabel = f'{timelabel}{sequencenumber}'
    tablename = f'{prefix}_{sequencenumber}_{fulltimelabel}'
    return tablename


def load_df_sqltable (engine: sqlalchemy.engine, df: pd.DataFrame, tablename: str):
    '''
    Load a table in pgsql db
    :param engine:
    :param df:
    :param tablename:
    :return: None
    '''
    df.to_sql(tablename, engine, if_exists='replace', index=False)

def delete_log (datapath: str):
    '''
    Delete log file
    :param datapath:
    '''
    if os.path.exists(datapath):
        os.remove(datapath)


# Build process---------------------------------------------------------------------------------------------------------

def build_extract (config, nrows, chunk_size):
    LOGFILE_PATH = config['logging_meta']['logfilepath']
    NROWS = nrows
    CHUNK_SIZE = chunk_size

    def extract ():
        logdf = read_data(LOGFILE_PATH, NROWS)
        logdfs = split_dataframe(logdf, CHUNK_SIZE)
        return logdfs

    return extract


def build_load_log_sqltables (config):
    driver = config['db_endpoint_meta']['driver']
    username = config['db_endpoint_meta']['username']
    password = config['db_endpoint_meta']['password']
    hostname = config['db_endpoint_meta']['hostname']
    port = config['db_endpoint_meta']['port']
    dbname = config['db_endpoint_meta']['dbname']
    prefix = config['table_meta']['prefix']
    timelabel = config['table_meta']['timelabel']

    def load_log_sqltables (logdfs):
        engine = create_connection(driver, username, password, hostname, port, dbname)
        try:
            for i, logdf in enumerate(logdfs, 1):
                tblname = set_tablename(prefix, str(i), timelabel)
                load_df_sqltable(engine, logdf, tblname)
        except RuntimeError as error:
            logging.error(error)

    return load_log_sqltables

def build_remove_log(config):

    LOGFILE_PATH = config['logging_meta']['logfilepath']

    def delete_log ():
        '''
        Delete log file
        :param datapath:
        '''
        if os.path.exists(LOGFILE_PATH):
            os.remove(LOGFILE_PATH)
    return delete_log


def main ():
    # Read configuration ----------------------------------------
    logging.info('Loading configuration file...')
    CONFIGPATH = './config/config.yaml'
    CONFIG = load_yaml(CONFIGPATH)

    # Build methods ----------------------------------------------
    logging.info('Building methods...')
    extract = build_extract(CONFIG, None, chunk_size=1000)
    load = build_load_log_sqltables(CONFIG)
    remove = build_remove_log(CONFIG)

    # Run the process ---------------------------------------
    logging.info('Reading log file for cluster file system...')
    logdfs = extract()
    logging.info('Loading performance logs in the backend postgres db...')
    load(logdfs)
    logging.info('Performance logs loaded successfully!')
    remove() # It's just for the demo. We should define a logrotate on k8s
    logging.info('Log file removed!')

if __name__ == '__main__':
    main()
