#The base image to build the Docker container from
FROM jupyter/datascience-notebook:6d42503c684f
MAINTAINER Ivan Nardini (ivan.nardini@sas.com)

USER root
RUN apt-get update && apt-get install -y \
    python3-dev \
    python3-pip \
    python3-venv
RUN chmod -R 777 /home/jovyan

USER jovyan
RUN conda create -n tfx_py36 python=3.6

#Set the working directory
WORKDIR /home/jovyan/
COPY requirements.txt /home/jovyan/requirements.txt

# Allow user to write to directory, delete /work, run custom postBuild
USER root
RUN chown -R $NB_USER /home/jovyan && \
    chmod -R 777 /home/jovyan

# Change back to user jovyan
USER jovyan

#Install libraries
RUN . /opt/conda/bin/activate tfx_py36
RUN pip install --upgrade pip
RUN pip install -r /home/jovyan/requirements.txt
RUN python3 -m pip install ipykernel
RUN python3 -m ipykernel install --user

# Expose the notebook port
EXPOSE 8888
