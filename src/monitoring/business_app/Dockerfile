FROM python:3
WORKDIR /business_app
COPY . /business_app
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 9999
CMD [ "python", "./app/api_caller_model.py" ]