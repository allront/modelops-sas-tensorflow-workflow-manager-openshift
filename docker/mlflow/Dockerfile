FROM python:3.7.0

RUN pip install mlflow==1.11.0

RUN mkdir /mlflow/

EXPOSE 5000

CMD mlflow server \
    --backend-store-uri /mlflow \
    --host 0.0.0.0
