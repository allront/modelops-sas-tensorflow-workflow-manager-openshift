# -*- coding: utf-8 -*-

"""
train is the module for retraining the champion model on server.

Steps:
"""

# General
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  # set before import tf
import functools
import shutil
import datetime
import logging
import yaml

# Analysis
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix

# Modelling
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, DenseFeatures, Dropout
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.losses import BinaryCrossentropy

# Settings
logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s',
                    datefmt='%m/%d/%Y %I:%M:%S %p',
                    level=logging.DEBUG)


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


def read_data (datapath: str) -> pd.DataFrame:
    '''
    Read csv for creating a nrows Dataframe
    :param datapath:
    :return: data
    '''
    df = pd.read_csv(datapath, sep=',')
    return df


def split_raw_train_test (raw_df: pd.DataFrame, test_size: float, random_state: int) -> tuple:
    '''
    Given raw data path and data directory, split the raw data
    in train and test
    :param raw_data_path:
    :return: dataframes
    '''
    train, test = train_test_split(raw_df, test_size=test_size, random_state=random_state)
    return train, test


def _set_categorical_type (dataframe: pd.DataFrame, categoricals: list) -> pd.DataFrame:
    '''
    Set the categorical type as string if neeeded
    :param dataframe:
    :return: dataframe
    '''
    for column in categoricals:
        if (dataframe[column].dtype == 'O'):
            dataframe[column] = dataframe[column].astype('string')
    return dataframe


def _set_categorical_empty (dataframe: pd.DataFrame, categoricals: list) -> pd.DataFrame:
    '''
    Change object type for categorical variable to avoid TF issue
    :param dataframe:
    :return: dataframe
    '''
    for column in categoricals:
        if any(dataframe[column].isna()):
            dataframe[column] = dataframe[column].fillna('')
    return dataframe


def _set_numerical_type (dataframe: pd.DataFrame, numericals: list) -> pd.DataFrame:
    '''
    Set the numerical type as float64 if needed
    :param dataframe:
    :return: dataframe
    '''
    for column in numericals:
        if (dataframe[column].dtype == 'int64'):
            dataframe[column] = dataframe[column].astype('float64')
    return dataframe


def _get_impute_parameters_cat (categorical_variables: list) -> dict:
    '''
    For each column in the categorical features, assign default value for missings.
    :param categorical_variables:
    :return: impute_parameters
    '''

    impute_parameters = {}
    for column in categorical_variables:
        impute_parameters[column] = 'Missing'
    return impute_parameters


def _get_mean_parameter (dataframe: pd.DataFrame, column: str) -> float:
    '''
    Given a DataFrame column, calculate mean
    :param dataframe:
    :param column:
    :return: mean
    '''
    mean = dataframe[column].mean()
    return mean


def _get_impute_parameters_num (dataframe: pd.DataFrame, numerical_variables: list) -> dict:
    '''
    Given a DataFrame and its numerical variables, return the associated dictionary of means
    :param dataframe:
    :param numerical_variables:
    :return: impute_parameters
    '''

    impute_parameters = {}
    for column in numerical_variables:
        impute_parameters[column] = _get_mean_parameter(dataframe, column)
    return impute_parameters


def _get_std_parameter (dataframe: pd.DataFrame, column: str) -> float:
    '''
    Given a DataFrame column, calculate std
    :param dataframe:
    :param column:
    :return: std
    '''
    std = dataframe[column].std()
    return std


def normalizer (column, mean, std):
    '''
    Given a column, Normalize with calculated mean and std
    :param column:
    :param mean:
    :param std:
    :return:
    '''
    return (column - mean) / std


def calculate_correlation_matrix (labels, predictions, p=0.5):
    '''
    Given labels and predictions columns,
    calculate confusion matrix for a given p
    :param labels:
    :param predictions:
    :param p:
    :return: corrmat
    '''
    corrmat = confusion_matrix(labels, predictions > p)
    return corrmat


def print_metrics (corrmat, metrics):
    '''
    Show evaluation matrix
    :param corrmat:
    :param metrics:
    :return: None
    '''
    print('Correlation matrix info')
    print('True Negatives - No default loans that pay', corrmat[0][0])
    print('False Positives - No default loans that dont pay', corrmat[0][1])
    print('False Negatives - Default loans that pay', corrmat[1][0])
    print('True Positives: - Default loans that dont pay', corrmat[1][1])
    print('Total Defauts: ', np.sum(corrmat[1]))
    print()
    print('-' * 20)
    print()
    print('Evalutation Metrics')
    for key, value in metrics.items():
        print(key, ':', value)


def setup (modelfolder):
    '''
    Given modelfolder, remove old version
    and create a new directory
    :param modelfolder:
    :return: modelfolder
    '''

    # if yes, delete it
    if os.path.exists(modelfolder):
        shutil.rmtree(modelfolder)
        print("Older ", modelfolder, " folder removed!")
    os.makedirs(modelfolder)
    print("Directory ", modelfolder, " created!")
    return modelfolder


def copytree (src, dst, symlinks=False, ignore=None):
    '''
    Given src and dst,
    it copies a directory or a files
    :param src:
    :param dst:
    :param symlinks:
    :param ignore:
    :return: None
    '''
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            shutil.copytree(s, d, symlinks, ignore)
        else:
            shutil.copy2(s, d)


# Build Pipeline -------------------------------------------------------------------------------------------------------
def build_ingest_data (config):
    DATAMETA = config['data_meta']
    FULL_DATAPATH = os.path.join(DATAMETA['datapath_out'], DATAMETA['datafile'])
    TEST_SIZE = DATAMETA['test_size']
    RANDOM_STATE = DATAMETA['random_state']

    def ingest_data ():
        raw_df = read_data(FULL_DATAPATH)
        data_train, data_test = split_raw_train_test(raw_df, TEST_SIZE, RANDOM_STATE)
        return data_train, data_test

    return ingest_data


def build_imputers (config, data_train):
    VARIABLES_SCHEMA_META = config['variables_schema_meta']
    CATEGORICAL_VARIABLES = VARIABLES_SCHEMA_META['categorical_predictors']
    NUMERICAL_VARIABLES = VARIABLES_SCHEMA_META['numerical_predictors']

    def _impute_missing_categorical (inputs: dict, target) -> dict:
        '''
        Given a tf.data.Dataset, impute missing in categorical variables with default 'missing' value
        :param inputs:
        :param target:
        :return: output, target
        '''
        impute_parameters = _get_impute_parameters_cat(CATEGORICAL_VARIABLES)
        # Since we modify just some features, we need to start by setting `outputs` to a copy of `inputs.
        output = inputs.copy()
        for key, value in impute_parameters.items():
            is_blank = tf.math.equal('', inputs[key])
            tf_other = tf.constant(value, dtype=np.string_)
            output[key] = tf.where(is_blank, tf_other, inputs[key])
        return output, target

    def _impute_missing_numerical (inputs: dict, target) -> dict:
        '''
        Given a tf.data.Dataset, impute missing in numerical variables with training means
        :param inputs:
        :param target:
        :return: output, target
        '''
        # Get mean parameters for imputing
        impute_parameters = _get_impute_parameters_num(data_train, NUMERICAL_VARIABLES)
        # Since we modify just some features, we need to start by setting `outputs` to a copy of `inputs.
        output = inputs.copy()
        for key, value in impute_parameters.items():
            # Check if nan (true, false mask)
            is_miss = tf.math.is_nan(inputs[key])
            # Store mean in a tf.constant
            tf_mean = tf.constant(value, dtype=np.float64)
            # Impute missing
            output[key] = tf.where(is_miss, tf_mean, inputs[key])
        return output, target

    def _get_normalization_parameters (numerical_variables: list) -> dict:
        '''
        For each numerical variable, calculate mean and std based on training dataframe
        :param numerical_variables:
        :return: normalize_parameters
        '''
        normalize_parameters = {}
        for column in numerical_variables:
            normalize_parameters[column] = {}
            normalize_parameters[column]['mean'] = _get_mean_parameter(data_train, column)
            normalize_parameters[column]['std'] = _get_std_parameter(data_train, column)
        return normalize_parameters

    return _impute_missing_categorical, _impute_missing_numerical, _get_normalization_parameters


def build_input_df (config, dataframe, _impute_missing_categorical, _impute_missing_numerical, mode='eval'):
    VARIABLES_SCHEMA_META = config['variables_schema_meta']
    CATEGORICAL_VARIABLES = VARIABLES_SCHEMA_META['categorical_predictors']
    NUMERICAL_VARIABLES = VARIABLES_SCHEMA_META['numerical_predictors']
    TARGET = VARIABLES_SCHEMA_META['target']
    EPOCHS = config['input_meta']['num_epochs']
    BATCH_SIZE = config['input_meta']['batch_size']

    def input_fn ():
        '''
        Extract data from pd.DataFrame, Impute and enhance data, Load data in parallel
        :return:
        '''

        # Extract
        df = _set_categorical_type(dataframe, CATEGORICAL_VARIABLES)
        df = _set_categorical_empty(df, CATEGORICAL_VARIABLES)
        df = _set_numerical_type(df, NUMERICAL_VARIABLES)
        predictors = dict(df)
        label = predictors.pop(TARGET)
        dataset = tf.data.Dataset.from_tensor_slices((predictors, label))

        # Transform
        dataset = dataset.map(_impute_missing_categorical)
        dataset = dataset.map(_impute_missing_numerical)

        if mode == 'train':
            dataset = dataset.repeat(EPOCHS)  # repeat the original dataset 3 times
            dataset = dataset.shuffle(buffer_size=1000, seed=8)  # shuffle with a buffer of 1000 element

        dataset = dataset.batch(BATCH_SIZE, drop_remainder=False)  # small batch size to print result

        # Load
        dataset = dataset.prefetch(1)  # It optimize training parallelizing batch loading over CPU and GPU

        return dataset

    return input_fn


def build_features (config, _get_normalization_parameters):
    VARIABLES_SCHEMA_META = config['variables_schema_meta']
    NUMERICAL_VARIABLES = VARIABLES_SCHEMA_META['numerical_predictors']
    VARIABLES_SCHEMA_META = config['variables_schema_meta']
    CATEGORICAL_VARIABLES = VARIABLES_SCHEMA_META['categorical_predictors']
    LABELS_DIC = config['labels_dict']

    def get_features ():
        '''
        Return a list of tf feature columns
        :param num_features:
        :param cat_features:
        :param labels_dict:
        :return: feature_columns
        '''
        # Create an empty list for feature
        feature_columns = []

        # Get numerical features
        normalize_parameters = _get_normalization_parameters(NUMERICAL_VARIABLES)
        for col_name in NUMERICAL_VARIABLES:
            mean = normalize_parameters[col_name]['mean']
            std = normalize_parameters[col_name]['std']
            normalizer_fn = functools.partial(normalizer, mean=mean, std=std)
            num_feature = tf.feature_column.numeric_column(col_name, dtype=tf.float32, normalizer_fn=normalizer_fn)
            feature_columns.append(num_feature)

        # Get categorical features
        for col_name in CATEGORICAL_VARIABLES:
            cat_feature = tf.feature_column.categorical_column_with_vocabulary_list(col_name, LABELS_DIC[col_name])
            indicator_column = tf.feature_column.indicator_column(cat_feature)
            feature_columns.append(indicator_column)

        return feature_columns

    return get_features


def build_estimator (config, feature_columns):
    MODEL_META = config['model_meta']
    TF_SEED = MODEL_META['tf_random_seed']
    LOGS_DIR = MODEL_META['logs_dir']
    N_CLASSES = MODEL_META['n_classes']
    BATCH_LAYER = MODEL_META['batch_layer']
    LEARNING_RATE = MODEL_META['lr']

    def get_estimator ():
        runconfig = tf.estimator.RunConfig(tf_random_seed=TF_SEED)
        boosted_trees_classifier = tf.estimator.BoostedTreesClassifier(
            model_dir=LOGS_DIR,
            feature_columns=feature_columns,
            n_classes=N_CLASSES,
            n_batches_per_layer=BATCH_LAYER,
            learning_rate=LEARNING_RATE
        )

        return boosted_trees_classifier

    return get_estimator


def build_train_pipeline (config):
    MODEL_META = config['model_meta']
    LOGS_DIR = MODEL_META['logs_dir']

    def train_pipeline ():
        logging.info('Prepare data for training...')
        ingest_data = build_ingest_data(config)
        data_train, data_test = ingest_data()

        logging.info('Define input_fn for training...')
        _impute_missing_categorical, _impute_missing_numerical, _get_normalization_parameters = build_imputers(config,
                                                                                                               data_train)
        train_input_fn = build_input_df(config, data_train, _impute_missing_categorical, _impute_missing_numerical,
                                        'train')
        test_input_fn = build_input_df(config, data_test, _impute_missing_categorical, _impute_missing_numerical)

        logging.info('Prepare features...')
        get_features = build_features(config, _get_normalization_parameters)
        features = get_features()

        logging.info('Build estimator...')
        get_estimator = build_estimator(config, features)
        estimator = get_estimator()

        logging.info('Start training...')
        shutil.rmtree(LOGS_DIR, ignore_errors=True)
        estimator_train = estimator.train(input_fn=train_input_fn)
        metrics = estimator_train.evaluate(input_fn=test_input_fn)
        return estimator_train, metrics, test_input_fn, data_test, features

    return train_pipeline


def build_evaluator (config):
    VARIABLES_SCHEMA_META = config['variables_schema_meta']
    TARGET = VARIABLES_SCHEMA_META['target']

    def evaluator (model, metrics, test_input_fn, data_test):
        predictions_dictionary = list(model.predict(test_input_fn))
        predictions = pd.Series([pred['class_ids'] for pred in predictions_dictionary])
        print_metrics(calculate_correlation_matrix(data_test[TARGET], predictions), metrics)

    return evaluator


def build_save_model_version (config):
    MODEL_META = config['model_meta']
    VERSION = MODEL_META['model_version']
    DATE = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    ID = "_".join([str(DATE), str(VERSION)])
    EXPORT_PATH = os.path.join(MODEL_META['modelpath_out'], ID)
    CHAMPION_PATH = MODEL_META['champion_path']

    def save_model_version (features, model):
        setup(MODEL_META['modelpath_out'])

        serving_input_fn = tf.estimator.export.build_parsing_serving_input_receiver_fn(
            tf.feature_column.make_parse_example_spec(features))
        modelpath_dir = model.export_saved_model(EXPORT_PATH, serving_input_fn)
        modelpath_dir = "/".join(modelpath_dir.decode("utf-8").split('/')[:-1])

        setup(CHAMPION_PATH)
        copytree(modelpath_dir, CHAMPION_PATH)
        
        return modelpath_dir

    return save_model_version


# Main -----------------------------------------------------------------------------------------------------------

def main ():
    # Read configuration ----------------------------------------
    logging.info('Loading configuration file...')
    CONFIGPATH = './config.yaml'
    CONFIG = load_yaml(CONFIGPATH)

    # Build pipeline --------------------------------------------
    logging.info('Compiling pipeline...')
    train_pipeline = build_train_pipeline(CONFIG)
    evaluator = build_evaluator(CONFIG)
    save_model_version = build_save_model_version(CONFIG)

    # Training pipeline -----------------------------------------
    logging.info('Training pipeline...')
    model, metrics, test_input_fn, data_test, features = train_pipeline()

    # Evaluate Training -----------------------------------------
    logging.info('Printing Test Evaluation metrics')
    evaluator(model, metrics, test_input_fn, data_test)

    # Save the model --------------------------------------------
    logging.info('Save the new version of the model...')
    model_path_dir = save_model_version(features, model)
    logging.info(f'The new model version is successfully stored in {model_path_dir}')

if __name__ == "__main__":
    main()
