FROM python:3
WORKDIR /logging_agent
COPY . /logging_agent
RUN pip install --no-cache-dir -r requirements.txt
RUN chmod +x ./wait-for-log.sh
EXPOSE 9998
ENTRYPOINT [ "./wait-for-log.sh", "/home/log.csv", "python", "./app/load_logs.py" ]
#"./logs/log.csv"
#/business_app/logs/log.csv