FROM python:3
WORKDIR /logging_agent
COPY . /logging_agent
RUN pip install --no-cache-dir -r requirements.txt
RUN chmod +x /wait-for-file.sh
EXPOSE 9998
CMD [ "./wait-for-postgres.sh", "log.csv", "python", "./app/load_logs.py" ]