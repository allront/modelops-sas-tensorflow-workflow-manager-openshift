FROM python:3.6
WORKDIR /transform_load
COPY . /transform_load
RUN pip install --no-cache-dir -r requirements.txt
RUN mkdir -m 777 ./data/val ./data/retrain
EXPOSE 9997
CMD [ "python", "./app/transform_load.py" ]