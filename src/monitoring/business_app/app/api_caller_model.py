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

import os
import yaml
import numpy as np
import pandas as pd
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

def get_data_list(datapath:str) -> list:
    '''
    Return csv data list
    :param datapath:
    :return: data_paths
    '''
    data_filenames = os.listdir(datapath)
    data_paths = [os.path.join(datapath, filename) for filename in data_filenames]
    return data_paths

def read_data(datapath: str, nrows=None) -> pd.DataFrame:
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

def set_target_predictors (dataframe: pd.DataFrame, target: str, inputs: list) -> tuple:
    '''
    Set target and predictors for scoring
    :param datapath:
    :param target:
    :param inputs:
    :param nrows:
    :return: target, predictors
    '''
    # Set target as dataframe to maintain index
    target = dataframe[[target]]
    predictors = dataframe[inputs]
    return target, predictors

def format_plain_input (string: str) -> str:
    '''
    Format plain input for scoring
    :param string:
    :return: format_record
    '''
    # Format record because keys need double quote
    format_string = str(string).replace("'", '"')
    # Format nan with NaN cause JSON conformance
    format_string = format_string.replace('nan', 'NaN')
    # Create the record for scoring
    plain_input_formatted = ''.join(['{"examples":[', format_string, ']}'])
    return plain_input_formatted

def set_plain_inputs (raw_inputs) -> list:
    '''
    Create a list of raw records dictionary
    :param raw_inputs:
    :return: plain_inputs
    '''
    # Read dataframe
    nrows = len(raw_inputs)
    raw_inputs_dictionary = raw_inputs.to_dict()
    # Create a list to store raw input records
    plain_inputs = []
    i = 0
    while i < nrows:
        # Create the column:value records dictionary to score
        plain_input = {column: row[i] for column, row in raw_inputs_dictionary.items()}
        plain_inputs.append(plain_input)
        i += 1
    return plain_inputs

def send_score_request (schema, ip, port, path, plain_input):
    '''
    Send API scoring request
    :param schema:
    :param ip:
    :param port:
    :param path:
    :param plain_input:
    :return: output
    '''
    # Create url
    url = '{0}://{1}:{2}/{3}'.format(schema, ip, port, path)
    # Format record for scoring
    plain_input_formatted = format_plain_input(plain_input)
    # Send the request
    try:
        response = requests.post(url, data=plain_input_formatted)
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        raise SystemExit(error)
    else:
        plain_output = response.json()
        return plain_output

def get_outputs_list (plain_inputs, schema, ip, port, path):
    '''
    Create a list of lists with infered labels and probabilities
    :param plain_inputs:
    :param schema:
    :param ip:
    :param port:
    :param path:
    :return: output_lists
    '''
    outputs_list = []
    for plain_input in plain_inputs:
        # Make the request
        plain_output = send_score_request(schema, ip, port, path, plain_input)
        plain_output = plain_output['results'][0]
        # Store each result in a list
        outputs_list.append(plain_output)
    return outputs_list

def set_outputs_dataframe(outputs_list, outputs):
    '''
    Set a dictionary with infered labels and probabilities
    :param outputs_list:
    :param outputs:
    :return: outputs_dataframe
    '''
    output_dictionaries_list = []
    for output_row in outputs_list:
        output_dictionary = {}
        # no_default_probability
        output_dictionary[outputs[0]] = output_row[0][1]
        # default_probabality
        output_dictionary[outputs[1]] = output_row[1][1]
        # em_probability
        output_dictionary[outputs[2]] = output_row[0][1] if output_row[0][1] > output_row[1][1] else output_row[1][1]
        # em_class
        output_dictionary[outputs[3]] = 0 if output_row[0][1] > 0.5 else 1
        output_dictionaries_list.append(output_dictionary)
    outputs_dataframe = pd.DataFrame(output_dictionaries_list)
    return outputs_dataframe

def set_logging_dataframe(data:pd.DataFrame, outputs: pd.DataFrame) -> pd.DataFrame:
    '''
    Join target, inputs and outputs based on index
    :param target:
    :param inputs:
    :param outputs:
    :return: logDf
    '''
    # Left merge with input data
    logDf = pd.merge(data, outputs, how='inner', left_index=True, right_index=True)
    return logDf

def write_logfile (logDf: pd.DataFrame, logpath:str):
    '''
    Write the log file with scored data
    :param logDf:
    :param logpath:
    :return:
    '''
    logDf.to_csv(logpath, sep=',', index=False)

# def main ():
#     CONFIGPATH = '../config/config.yaml'
#     pass

if __name__ == '__main__':
    DATAPATH = '../data'
    CONFIGPATH = '../config/config.yaml'
    CONFIG = load_yaml(CONFIGPATH)
    DATA_META = CONFIG['data_meta']
    DATA_PATH = DATA_META['datapath']
    VARIABLE_SCHEMA_META = CONFIG['variables_schema_meta']
    TARGET = VARIABLE_SCHEMA_META['target']
    INPUTS = VARIABLE_SCHEMA_META['inputs']
    OUTPUTS = VARIABLE_SCHEMA_META['outputs']
    MODEL_ENDPOINT_META = CONFIG['model_endpoint_meta']
    SCHEMA = MODEL_ENDPOINT_META['schema']
    IP = MODEL_ENDPOINT_META['ip']
    PORT = MODEL_ENDPOINT_META['port']
    PATH = MODEL_ENDPOINT_META['path']
    LOGGING_META = CONFIG['logging_meta']
    LOG_PATH = LOGGING_META['logpath']
    DATALIST = get_data_list(DATAPATH)
    data = read_data(DATAPATH)
    target, inputs = set_target_predictors(data,
                                       TARGET,
                                       INPUTS)
    plain_inputs = set_plain_inputs(inputs)
    scored_data_list = get_outputs_list(plain_inputs, SCHEMA, IP, PORT, PATH)
    outputs = set_outputs_dataframe(scored_data_list, OUTPUTS)
    logDf = set_logging_dataframe(data, outputs)
    write_logfile(logDf, LOG_PATH)