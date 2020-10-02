from src.monitoring.business_app.api_caller_model import set_raw_records

DATAPATH='./data/perf_1_q1.csv'
def test_set_raw_records ():
    assert set_raw_records(DATAPATH)
