import pytest
from src.monitoring.business_app.api_caller_model import set_raw_records

DATAPATH='./data/perf_1_q1.csv'
TARGET='BAD'

@pytest.mark.parametrize("nrows", [10, 20, 30])
def test_set_raw_records(nrows):
    assert type(set_raw_records(DATAPATH, TARGET, nrows)) is list
