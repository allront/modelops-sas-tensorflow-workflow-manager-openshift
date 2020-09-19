import pytest
from prebuild.prebuild import get_authorization, get_project_id, get_champion_id, get_model_content_id, get_model_artefact

# Variables
SERVER = 'http://10.96.14.134'
AUTHURI = '/SASLogon/oauth/token'
USERNAME = 'sasdemo'
PASSWORD = 'Orion123'
MODELREPO_ENDPOINT = '/modelRepository/'
PROJECT_NAME = 'snam_modelops_tensorflow'
MODEL_PATH = './model'
MODEL_NAME = 'champion_model.zip'


def test_get_authorization ():
    assert get_authorization(SERVER, AUTHURI, USERNAME, PASSWORD) is not None;
    assert type(get_authorization(SERVER, AUTHURI, USERNAME, PASSWORD)) is str;


TOKEN = get_authorization(SERVER, AUTHURI, USERNAME, PASSWORD)


@pytest.mark.parametrize('token', [TOKEN])
def test_get_project_id (token):
    assert get_project_id(SERVER, token, MODELREPO_ENDPOINT, PROJECT_NAME) is not None;
    assert type(get_project_id(SERVER, token, MODELREPO_ENDPOINT, PROJECT_NAME)) is str;


PROJECT_ID = get_project_id(SERVER, TOKEN, MODELREPO_ENDPOINT, PROJECT_NAME)


@pytest.mark.parametrize('project_id', [PROJECT_ID])
def test_get_champion_id (project_id):
    assert get_champion_id(SERVER, TOKEN, MODELREPO_ENDPOINT, project_id) is not None;
    assert type(get_champion_id(SERVER, TOKEN, MODELREPO_ENDPOINT, project_id)) is str;


CHAMPION_ID = get_champion_id(SERVER, TOKEN, MODELREPO_ENDPOINT, PROJECT_ID)


@pytest.mark.parametrize('champion_id', [CHAMPION_ID])
def test_get_model_content_id (champion_id):
    assert get_model_content_id(SERVER, TOKEN, MODELREPO_ENDPOINT, CHAMPION_ID) is not None;
    assert type(get_model_content_id(SERVER, TOKEN, MODELREPO_ENDPOINT, CHAMPION_ID)) is str;


MODEL_CONTENT_ID = get_model_content_id(SERVER, TOKEN, MODELREPO_ENDPOINT, CHAMPION_ID)


@pytest.mark.parametrize('model_content_id', [MODEL_CONTENT_ID])
def test_get_model_artefact (model_content_id):
    assert get_model_artefact(SERVER, TOKEN, MODELREPO_ENDPOINT, CHAMPION_ID,
                              MODEL_CONTENT_ID, MODEL_PATH, MODEL_NAME) == 0;
