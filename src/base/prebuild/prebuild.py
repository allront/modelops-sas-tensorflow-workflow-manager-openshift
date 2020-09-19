#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
prebuild.py is a module to download model content from project
Steps:
1 - Connection to Viya
2 - Get Project ID
3 - Get Champion ID
4 - Get Model Content ID
5 - Download Model Artefact
"""
#LIBRARIES
import requests
import base64
import json
import sys
import os
import ruamel.yaml as yaml
import logging as log
log.basicConfig(format='%(asctime)s %(levelname)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p',
                        level=log.INFO)
import warnings
warnings.simplefilter('ignore', yaml.error.UnsafeLoaderWarning)

#  Connection to Viya

def get_authorization(server: str, authUri:str, username:str, password:str) -> str:

    '''
    Get Token for connection to Viya
    :param server:
    :param authUri:
    :param username:
    :param password:
    :return: token
    '''

    url = "".join([server, authUri])
    params = {"grant_type": 'password',
              "username": username,
              "password": password}
    headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': "Basic {}".format(base64.b64encode(b'sas.ec:').decode(encoding='utf8'))
    }
    try:
        response = requests.post(url, params=params, headers=headers)
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        raise SystemExit(error)
    else:
        token = json.loads(response.text)['access_token']
        return token

#  Get Project ID

def get_project_id(server: str, token: str, modelrepo_endpoint: str, project_name: str) -> str:

    '''
    Get the project id
    :param server:
    :param token:
    :param modelrepo_endpoint:
    :param project_name:
    :return: project_id:
    '''

    flt = "projects?filter=eq(name, '" + project_name + "'" + ")"
    url = "".join([server, modelrepo_endpoint, flt])

    headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token
    }
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        raise SystemExit(error)
    else:
        content = json.loads(response.text)
        if not content['items']:
            raise Exception('{} not found. Please check model repository!'.format(project_name))
        project_id = content['items'][0]['id']
        return project_id


#  Get Champion ID

def get_champion_id(server: str, token: str, modelrepo_endpoint: str, project_id: str) -> str:
    '''
    Get Champion id
    :param server:
    :param token:
    :param modelrepo_endpoint:
    :param project_id:
    :return champion_id:
    '''
    champion_endpoint = 'projects/' + project_id + '/champion'
    url = "".join([server, modelrepo_endpoint, champion_endpoint])
    headers = {
        'Accept': 'application/vnd.sas.models.model+json',
        'Authorization': 'Bearer ' + token
    }
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        raise SystemExit(error)
    else:
        content = json.loads(response.text)
        if not content['id']:
            raise Exception('Champion model not found.'
                            'Please check Champion Model in the project!')
        champion_id = content['id']
        return champion_id

#  Get Model Content id
def get_model_content_id(server: str, token: str, modelrepo_endpoint: str, champion_id: str) -> str:
    '''
    Get Model Content ID for referencing the model to download
    :param server:
    :param token:
    :param modelrepo_endpoint:
    :param champion_id:
    :return: model_content_id
    '''
    contents_endpoint = '/models/' + champion_id + '/contents'
    url = "".join([server, modelrepo_endpoint, contents_endpoint])
    headers = {
        'Accept': 'application/vnd.sas.collection+json',
        'Authorization': 'Bearer ' + token
    }
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        raise SystemExit(error)
    else:
        content = json.loads(response.text)
        items = [(item['name'], item['id']) for item in content['items']]
        if any(".zip" in item[0] for item in items): #check if a content is a .zip file:
            model_content = [item for item in items if ".zip" in item[0]] #pick the file
            #model_content_name = model_content[0][0]
            model_content_id = model_content[0][1]
        else:
            raise Exception("There is no model zip file. Please check the repository.")
        return model_content_id

# Download Model Artefact
def get_model_artefact(server: str, token: str, modelrepo_endpoint: str,
                       champion_id: str, model_content_id: str,
                       model_path: str, model_name: str) -> int:
    '''
    Download the model artefact
    :param server:
    :param token:
    :param modelrepo_endpoint:
    :param champion_id:
    :param model_content_id:
    :param model_path:
    :param model_name:
    :return: None
    '''
    content_endpoint = '/models/' + champion_id + '/contents/' + model_content_id + '/content'
    url = "".join([server, modelrepo_endpoint, content_endpoint])
    headers = {
        "Content-Type": "application/octet-stream",
        "Authorization": "Bearer " + token
    }
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        raise SystemExit(error)
    else:
        if not os.path.exists(model_path):
            os.makedirs(model_path)
        with open(os.path.join(model_path, model_name), "wb") as data:
            for content in response.iter_content():
                data.write(content)
        data.close()
        return 0
#  Main
def main():
    # Read configuration
    CONFIGPATH = sys.argv[1]

    stream = open(CONFIGPATH, 'r')
    config = yaml.load(stream)

    # Variables
    SERVER = config['connection']['server']
    AUTHURI = config['connection']['authUri']
    USERNAME = config['connection']['username']
    PASSWORD = config['connection']['password']
    MODELREPO_ENDPOINT = config['endpoints']['modelrepository_endpoint']
    PROJECT_NAME = config['modelrepository_meta']['project_name']
    MODEL_PATH = config['server_meta']['model_path']
    MODEL_NAME = config['server_meta']['model_artefact_name']

    log.info("Get Token...")
    TOKEN = get_authorization(SERVER, AUTHURI, USERNAME, PASSWORD)
    log.info('Get Project ID...')
    PROJECT_ID = get_project_id(SERVER, TOKEN, MODELREPO_ENDPOINT, PROJECT_NAME)
    log.info('Get Champion ID...')
    CHAMPION_ID = get_champion_id(SERVER, TOKEN, MODELREPO_ENDPOINT, PROJECT_ID)
    log.info('Get Model Content ID...')
    MODEL_CONTENT_ID = get_model_content_id(SERVER, TOKEN, MODELREPO_ENDPOINT, CHAMPION_ID)
    log.info('Downloading Model Content...')
    STATUS = get_model_artefact(SERVER, TOKEN, MODELREPO_ENDPOINT, CHAMPION_ID, MODEL_CONTENT_ID, MODEL_PATH, MODEL_NAME)
    if STATUS != 0:
        log.error("Unable to download model artefact!")
    return STATUS

if __name__ == "__main__":
    main()









