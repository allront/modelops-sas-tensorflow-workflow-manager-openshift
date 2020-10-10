#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
api_caller_model is an application to simulate a business application that calls
Tensorflow models.
Steps:
1- Load the data
2- Score the data via API calls
3- Log the scored data
"""

import os
import yaml
import pandas as pd
import requests
import uuid
import time
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


def set_plain_inputs (raw_inputs: pd.DataFrame) -> list:
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


def send_score_request (schema: str, ip: str, port: int, path: str, plain_input: list) -> str:
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


def get_outputs_list (plain_inputs: list, schema: str, ip: str, port: int, path: str) -> list:
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


def set_outputs_dataframe (outputs_list: list, outputs: list) -> pd.DataFrame:
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


def set_logging_dataframe (data: pd.DataFrame, outputs: pd.DataFrame) -> pd.DataFrame:
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


def write_log (logdataframes: list, logpath: str):
    full_logdf = pd.concat(logdataframes)
    logname = 'log.csv'
    fulllogpath = f'{logpath}{logname}'
    full_logdf.to_csv(fulllogpath, sep=',', index=False)


def print_logs (logDf, nrows) -> list:
    '''
    Set log
    :param logDf:
    :param nrows:
    :return:
    '''

    # Read dataframe
    raw_output_dictionary = logDf.to_dict()
    i = 0
    while i < nrows:
        # Create the column:value records dictionary to score
        plain_output = {column: row[i] for column, row in raw_output_dictionary.items()}
        id = uuid.uuid1().hex
        logging.info(
            f'Scoring request {id}. Predicted Class {plain_output["EM_CLASSIFICATION"]} with probability {round(plain_output["EM_PROBABILITY"], 3)}')
        time.sleep(1)
        i += 1


# Build process steps --------------------------------------------------------------------------------------------------
def build_load (config, nrows):
    VARIABLE_SCHEMA_META = config['variables_schema_meta']
    NROWS = nrows

    def load (datafile: str):
        '''
        Load process
        :param datafile:
        :param nrows:
        :return: plain_inputs
        '''

        data = read_data(datafile, nrows=NROWS)

        target, inputs = set_target_predictors(data,
                                               VARIABLE_SCHEMA_META['target'],
                                               VARIABLE_SCHEMA_META['inputs'])

        plain_inputs = set_plain_inputs(inputs)

        return data, plain_inputs

    return load


def build_score (config):
    MODEL_ENDPOINT_META = config['model_endpoint_meta']
    VARIABLE_SCHEMA_META = config['variables_schema_meta']

    def score (plain_inputs):
        '''
        Score process
        :param datafile:
        :param nrows:
        :return: logDf
        '''

        scored_data_list = get_outputs_list(plain_inputs,
                                            MODEL_ENDPOINT_META['schema'],
                                            MODEL_ENDPOINT_META['ip'],
                                            MODEL_ENDPOINT_META['port'],
                                            MODEL_ENDPOINT_META['path'])

        outputs = set_outputs_dataframe(scored_data_list,
                                        VARIABLE_SCHEMA_META['outputs'])

        return outputs

    return score


def build_log ():
    def log (data, outputs):
        logDf = set_logging_dataframe(data, outputs)
        return logDf

    return log


def build_write (config):
    LOGPATH = config['logging_meta']['logpath']

    def write (logdfs):
        write_log(logdfs, LOGPATH)

    return write


def iterator (config, load, score, log) -> list:
    '''
    An iterator of the steps.
    :param CONFIG:
    :param load:
    :param score:
    :param log:
    :return: log_dataframes
    '''
    datapath = config['data_meta']['datapath']
    data_sources = get_data_list(datapath)
    log_dfs = []

    for i, datafile in enumerate(data_sources, start=1):
        data, plain_inputs = load(datafile)
        outputs = score(plain_inputs)
        logdf = log(data, outputs)
        log_dfs.append(logdf)
    return log_dfs


def main ():
    # Read configuration ----------------------------------------
    logging.info('Loading scoring configuration file...')
    CONFIGPATH = './config/config.yaml'
    CONFIG = load_yaml(CONFIGPATH)
    NROWS = 1000

    # Build methods ---------------------------------------------
    logging.info('Building methods...')
    load = build_load(CONFIG, NROWS)
    score = build_score(CONFIG)
    log = build_log()
    write = build_write(CONFIG)

    # Iterate the process ---------------------------------------
    # Notice we can consider to parallelize the process
    # But for the demo purpose it is ok
    logging.info('Initiating scoring process...')
    log_dataframes = iterator(CONFIG, load, score, log)

    # Write log file --------------------------------------------
    logging.info('Creating log file...')
    write(log_dataframes)
    logging.info('Logfile created!')

    # Print logs ------------------------------------------------
    for log in log_dataframes:
        print_logs(log, NROWS)


if __name__ == '__main__':
    main()
