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
def read_yaml(configpath:str)->dict:
    '''
    Given file path, Read yaml file
    :param configpath:
    :return: conn_dict
    '''
    with open(configpath) as file:
        conn_dict = yaml.load(file, Loader=yaml.FullLoader)
    return conn_dict

def json_formatter(string: str)->str:
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

def set_raw_records(datapath: str, nrows: int) -> list:
    '''
    Create a list of raw records dictionary
    :param datapath:
    :param nrows:
    :return: raw_records
    '''
    # Read dataframe
    raw_input_dictionary = pd.read_csv(datapath, sep=',').to_dict()
    # Drop target variable
    #raw_input_dictionary.pop(target)
    # Create a list to store raw records
    raw_records = []
    i = 0
    while i < nrows:
        raw_record = {column: row[i] for column, row in raw_input_dictionary.items()}
        raw_records.append(raw_record)
        i += 1
    return raw_records

def score_request(schema, ip, port, path, record):
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

def write_logfile():
    pass



# Create a logging for each request

if __name__ == '__main__':
    DATAPATH = './data/perf_1_q1.csv'
    CONFIGPATH = './config/config.yaml'
    CONFIG = read_yaml(CONFIGPATH)
    MODEL_ENDPOINT_META = CONFIG['model_endpoint']
    raw_records = set_raw_records(DATAPATH, 'BAD', 10)
    for record in raw_records:
        score_request(MODEL_ENDPOINT_META['schema'],
                  MODEL_ENDPOINT_META['ip'],
                  MODEL_ENDPOINT_META['port'],
                  MODEL_ENDPOINT_META['path'],
                  record)

