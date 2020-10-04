FROM python:3
WORKDIR /business_app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . /business_app
EXPOSE 9999
WORKDIR /business_app/app
CMD [ "python", "./api_caller_model.py" ]
