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
import pandas as pd
import requests
import time
import logging

# Helpers

def set_raw_records(datapath:str) -> dict:
    # Create a dictionary of raw records
    raw_input = pd.read_csv(datapath, sep=',')
    raw_input_dictionary = raw_input.to_dict()
    print(raw_input_dictionary)

# Create a logging for each request

# Request example 
# curl -v -d '{"instances": [1.0, 2.0, 5.0]}' -X POST http://championmodel-deploymodel1.10.249.20.186.nip.io/v1/models/champion_model:predict
# Notice server domain may change.
# Notice endpoint /champion_model:predict may change as well
