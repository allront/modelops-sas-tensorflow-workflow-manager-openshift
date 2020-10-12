FROM python:3.6
WORKDIR /trasform_load
COPY . /trasform_load
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 9997
CMD [ "python", "./app/trasform_load.py" ]