# -*- coding: utf-8 -*-

"""
extract_trasform_load is an application to read extracted performance data from SAS Viya
and create data for retraining.

Steps:
1- Extract performance data from psql database
2- Read performance csv files in pandas Dataframe
3- Append one to another
4- Load on disk the training dataset

Author: Ivan Nardini (ivan.nardini@sas.com)
"""

import os
import yaml
import sqlalchemy
from sqlalchemy import create_engine
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


def write_get_table_names_query (tableprefix: str) -> str:
    '''
    Write query for getting table names
    :param tableprefix:
    :return: query
    '''
    query = """
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name like '{}%';    
    """.format(tableprefix)
    return query


def get_table_metas_list (connection: sqlalchemy.engine, query: str) -> list:
    '''
    Get list of table names
    :param connection:
    :param query:
    :return: tbl_names
    '''
    tbl_metas = pd.read_sql(query, connection).values.tolist()
    return tbl_metas


def write_select_tables_query (tablenames: list) -> str:
    '''
    Write select queries
    :param tablenames:
    :return: queries
    '''
    queries = []
    for tableschema, tablename in tablenames:
        query = """
        SELECT *
        FROM {}."{}";
        """.format(tableschema, tablename)
        queries.append(query)
    return queries

def extract_tables (connection, queries):
    '''
    Extraxt tables from Postgres
    :param connection:
    :param queries:
    :return: dfs
    '''
    dfs = [pd.read_sql_query(query, connection) for query in queries]
    return dfs

def select_columns (dataframe: pd.DataFrame, labels: list) -> pd.DataFrame:
    '''
    Select columns for retraining
    :param labels:
    :return: df
    '''
    df = dataframe[labels]
    return df

def create_training_dataframe (raw_dfs: list, labels: list) -> pd.DataFrame:
    '''
    Append dataframes one to another
    :param datapaths:
    :return: train_df
    '''
    dfs = [select_columns(df, labels) for df in raw_dfs]
    train_df = pd.concat(dfs)
    return train_df

def write_traindf (train_df: pd.DataFrame, datapath: str):
    '''
    Write training dataframe
    :param train_df:
    :param datapath:
    :return: None
    '''

    filename = 'retrain.csv'
    full_datapath = os.path.join(datapath, filename)
    train_df.to_csv(full_datapath, sep=',', index=False)


# Build Process --------------------------------------------------------------------------------------------------------
def build_extract (config):
    driver = config['db_endpoint_meta']['driver']
    username = config['db_endpoint_meta']['username']
    password = config['db_endpoint_meta']['password']
    hostname = config['db_endpoint_meta']['hostname']
    port = config['db_endpoint_meta']['port']
    dbname = config['db_endpoint_meta']['dbname']
    tableprefix = config['table_meta']['prefix']

    def extract ():
        conn = create_connection(driver, username, password, hostname, port, dbname)
        query = write_get_table_names_query(tableprefix)
        table_metas = get_table_metas_list(conn, query)
        queries = write_select_tables_query(table_metas)
        dfs = extract_tables(conn, queries)
        return dfs

    return extract


def build_transform (config):
    VARIABLE_META_DATA = config['variables_schema_meta']

    def transform (dfs):
        train_df = create_training_dataframe(dfs, VARIABLE_META_DATA['labels'])
        return train_df

    return transform


def build_load (config):
    DATAMETA = config['data_meta']

    def load (train_df):
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
    extract = build_extract(CONFIG)
    transform = build_transform(CONFIG)
    load = build_load(CONFIG)

    # Run the process --------------------------------------------
    logging.info('Extract performance data from Viya Postgresql...')
    dfs = extract()
    logging.info('Transforming performance data for retraining...')
    train_df = transform(dfs)
    logging.info('Creating retrain file...')
    load(train_df)
    logging.info('Retrain file created!')


if __name__ == '__main__':
    main()
