
#Libraries
import glob
import os
import sys
import time
import pandas as pd
import swat

# Session variable
_HOST = '172.28.235.136'
_PORT = '5570'
_USERNAME = 'sasdemo'
_PASSWORD = 'Orion123'
_CASLIB = 'Public'

_PATH="./Data/performances/*.csv"
_MODEL_ID="_322d1b0c-8846-4d52-84b9-d6d966161614_champion"


# Start CAS Session

cas_session = swat.CAS(_HOST, _PORT, _USERNAME, _PASSWORD)

out = cas_session.serverstatus()
# print(out)

# For each csv, load into caslib Public with 30 secs
print("Loading Performance Table...")

for tblpath in glob.glob(_PATH):
    try: 
        tbl_csv = os.path.basename(tblpath)
        df = pd.read_csv(tblpath, sep=';', header=0)
        # replace=True
        # print(tbl_csv)
        tblname = tbl_csv[:-4] + _MODEL_ID
        perftbl = cas_session.upload_frame(df, casout=dict(name=str(tblname), caslib=_CASLIB, promote=True))
        time.sleep(5)
    except:
        print(sys.exc_info()[0],"occured.")