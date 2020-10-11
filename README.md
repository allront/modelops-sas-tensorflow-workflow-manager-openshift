# Operationalizing a Tensorflow Models with SAS Model Manager on Red Hat OpenShift Container Platform

The goal of this scenario is to answer just one question: 

**Is It possible to operationalize a TensorFlow model versioned in SAS Model Manager on Red Hat OpenShift Container Platform?**

And the answer is: **Yes, of course. Thanks to SAS Workflow Manager**

## Overview

**Simple product demos are enough anymore.** 

And when we talk about operationalizing open source models, 

**customer asks to prove how SAS Model Manager can be integrated with 3th party systems**.

In this scenario, we deal with one of the common cases we face recently. 

Below **the high-level architecture of the solution**:

<p align="center">
<img src="https://github.com/IvanNardini/modelops-sas-tensorflow-workflow-manager-openshift/raw/master/architecture_4.png">
</p>

## Scenario Description

1. Data Scientist runs **TensorFlow model** experiments in Development environment and track them using **Mlflow**
 
2. He/She registers the Champion candidate in **SAS Model Manager** with **SAS PZMM** and **SASCTL** libraries

3. The Champion model is subjected to a validation process. If it passes, the model is deployed on **RedHat Openshift (OKD)**
thanks to **SAS Workflow Manager** using **Google's Tensorflow serving image** in a OKD project previously created by IT Cluster Admin.  

4. IT deploys an application stack to simulate scoring requests and includes a dedicated sidecar container for pushing logs directly to a backend 
Logs are store in a **PostgresSQL** database and consumed by performance monitoring service that sends a notification in case model underscores. 

Assuming time goes and model starts underperformed...

5. **SAS Workflow Manager** triggers automated retraining based on the on-field data and sends message to **Microsoft Teams**.

6. Data Scientist receives the notification and he/she starts a new training process. 

## Contact Information
Your comments and suggestions are valuable and most welcome. Contact authors at:

- Ivan Nardini (ivan.nardini@sas.com), Sr. Customer Advisor, SAS Italy

- Artem Glazkov (artem.glazkov@sas.com), Sr. Consultant, SAS Russia

## Contributing

We welcome your contributions! Feel free to reach us!

## References 

1. https://www.densify.com/articles/deploy-minishift-public-cloud
2. https://www.tensorflow.org/guide
3. https://www.openshift.com/blog/remotely-push-pull-container-images-openshift
4. https://communities.sas.com/t5/SAS-Communities-Library/SAS-Viya-3-5-SAS-Studio-and-SAS-Compute-Server-non-functional/ta-p/616617
5. https://learn.openshift.com/
6. https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/

