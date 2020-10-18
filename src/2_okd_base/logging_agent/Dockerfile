FROM python:3.6
WORKDIR /logging_agent
COPY . /logging_agent
RUN pip install --no-cache-dir -r requirements.txt
RUN chmod +x ./wait-for-log.sh
EXPOSE 9998
ENTRYPOINT [ "./wait-for-log.sh", "/log/log.csv", "python", "./app/load_logs.py" ]
#"./logs/log.csv"
