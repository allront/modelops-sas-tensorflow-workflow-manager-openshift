#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
api_caller_model is an application to simulate a business application that calls
Tensorflow models.
Steps:
1- Read the data in a dictionary
2- Send api scoring request
3- Store input and output in a log file
"""
import numpy as np
import pandas as pd
import yaml
import requests
import time
import logging


# Helpers
def load_yaml (configpath: str) -> dict:
    '''
    Given file path, Read yaml file
    :param configpath:
    :return: conn_dict
    '''
    with open(configpath) as file:
        conn_dict = yaml.load(file, Loader=yaml.FullLoader)
    return conn_dict


def read_raw_data (datapath: str, target: str, inputs: list) -> tuple:
    '''
    Read target and inputs
    :param datapath:
    :param target:
    :param inputs:
    :return:
    '''
    raw_dataframe = pd.read_csv(datapath, sep=';')
    # Set target as dataframe to maintain index
    target = raw_dataframe[[target]]
    inputs = raw_dataframe[inputs]
    return target, inputs


# Score inputs
def json_formatter (string: str) -> str:
    '''
    Format record for scoring
    :param string:
    :return: format_record
    '''
    # Format record because keys need double quote
    format_string = str(string).replace("'", '"')
    # Format nan with NaN cause JSON conformance
    format_string = format_string.replace('nan', 'NaN')
    # Create the record for scoring
    format_record = ''.join(['{"examples":[', format_string, ']}'])
    return format_record


def set_plain_inputs (raw_inputs, nrows: int) -> list:
    '''
    Create a list of raw records dictionary
    :param datapath:
    :param nrows:
    :return: raw_records
    '''
    # Read dataframe
    raw_inputs_dictionary = raw_inputs.to_dict()
    # Drop target variable
    # raw_input_dictionary.pop(target)
    # Create a list to store raw records
    plain_inputs = []
    i = 0
    while i < nrows:
        plain_input = {column: row[i] for column, row in raw_inputs_dictionary.items()}
        plain_inputs.append(plain_input)
        i += 1
    return plain_inputs


def score_request (schema, ip, port, path, record):
    '''
    Send API scoring request
    :param schema:
    :param ip:
    :param port:
    :param path:
    :param record:
    :return:
    '''
    # Create url
    url = '{0}://{1}:{2}/{3}'.format(schema, ip, port, path)
    # Format record for scoring
    format_record = json_formatter(record)
    response = requests.post(url, data=format_record)
    if response.ok:
        output = response.json()
    else:
        output = {}
    return output

def scored_data_list (plain_inputs, schema, ip, port, path):
    probabilities_list = []
    for plain_input in plain_inputs:
        plain_output = score_request(schema, ip, port, path, plain_input)
        probability = plain_output['results'][0][0][1]
        scored_data_list.append(probability)
    return probabilities_list

# Create dataframe with outputs colums (P_BAD0, P_BAD1, EM_PROB, EM_CLASS)
# def log_formatter (inputs, output):
#     log_dataframe = pd.DataFrame()
#     log_dataframe.columns()
#     # Convert list of dictionary in a dataframe
#     output = pd.DataFrame()
#     # Set dataframe columns
#     outputDf.columns = outputcols
#     # merge with input data
#     outputDf = pd.merge(inputDf, outputDf, how='inner', left_index=True, right_index=True)


def write_logfile ():
    pass


def main ():
    pass


if __name__ == '__main__':
    DATAPATH = './data/perf_1_q1.csv'
    CONFIGPATH = './config/config.yaml'
    CONFIG = load_yaml(CONFIGPATH)
    VARIABLE_SCHEMA = CONFIG['variables_schema']
    TARGET = VARIABLE_SCHEMA['target']
    INPUTS = VARIABLE_SCHEMA['inputs']
    MODEL_ENDPOINT_META = CONFIG['model_endpoint']
    SCHEMA = MODEL_ENDPOINT_META['schema']
    IP = MODEL_ENDPOINT_META['ip']
    PORT = MODEL_ENDPOINT_META['port']
    PATH = MODEL_ENDPOINT_META['path']

    target, raw_inputs = read_raw_data(DATAPATH,
                                       TARGET,
                                       INPUTS)
    plain_inputs = set_plain_inputs(raw_inputs, 10)
    scored_data_list = scored_data_list(plain_inputs, SCHEMA, IP, PORT, PATH)
