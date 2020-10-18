/*************************************************************
*************** Notify Retrain Model Job *********************
**************************************************************

Program Name : notify_retrain_status_4.sas
Owner : ivnard that developed this code
Program Description : Send a notification on MS team
for retraining model status

**************************************************************
**************************************************************
**************************************************************/

options noquotelenmax;
filename logfile '/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/logs/notify4.log';

proc printto log=logfile;
run;

filename resp TEMP;
filename content TEMP;

data _null_;
file content;
input;
put _infile_;
datalines;
{
	"@type": "MessageCard",
	"@context": "https://schema.org/extensions",
	"summary": "This is the summary property",
	"themeColor": "0075FF",
	"sections": [
		{
			"startGroup": true,
			"title": "**SAS Workflow Manager Process Notification**",
			"activityImage": "https://cdn0.iconfinder.com/data/icons/social-messaging-ui-color-shapes/128/notification-circle-blue-512.png",
			"activityTitle": "",
			"activitySubtitle": "",
			"facts": [
				{
					"name": "Title:",
					"value": "**Retraining Status**"
				},
				{
					"name": "Details:",
					"value": "Retraining process successfully completed! A new version of the model is registered in SAS Model Manager"
				},
				{
					"name": "Current Status:",
					"value": "Approval is required to ship the new version. Please check the project repository"
				}
			]
		}
	]
}
;
run;

proc http
  /* Substitute your webhook URL here */
  url="<yourwebhook>"
  method="POST"
  in=content
  out=resp;
run;


/* libname resps JSON fileref=resp; */
/*  */
/* data _null_; */
/* set resps.ROOT; */
/* call symputx( "statusId", status); */
/* run; */
/*  */
/* data _null_; */
/* put "&statusId."; */
/* run; */

filename resp clear;