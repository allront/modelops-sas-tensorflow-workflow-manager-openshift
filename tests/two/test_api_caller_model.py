import pytest
from src.monitoring.business_app.api_caller_model import set_raw_records, score_request

datapath_params = ['./data/perf_1_q1.csv', './data/perf_2_q2.csv', './data/perf_3_q3.csv', './data/perf_4_q4.csv']
nrows_params = [10, 20, 30]


@pytest.mark.parametrize("datapath", datapath_params)
@pytest.mark.parametrize("nrows", nrows_params)
def test_set_raw_records (datapath, nrows):
    assert type(set_raw_records(datapath, nrows)) is list


schema = 'http'
ip = 'localhost'
port = '8501'
path = 'v1/models/model:classify'
record = {"examples": [
    {'LOAN': 34400.0, 'MORTDUE': 97971.0, 'VALUE': 145124.0, 'YOJ': 13.0, 'DEROG': 0.0, 'DELINQ': 0.0, 'CLAGE': 67.832,
     'NINQ': 1.0, 'CLNO': 36.0, 'DEBTINC': 40.402, 'REASON': 'DebtCon', 'JOB': 'Other'}]}

def test_score_request ():
    assert type(score_request(schema, ip, port, path, record)) is dict
