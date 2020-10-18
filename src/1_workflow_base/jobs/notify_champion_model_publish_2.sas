/*************************************************************
*************** Notify Champion Publish Job ******************
**************************************************************

Program Name : notify_champion_model_publish_2.sas
Owner : ivnard that developed this code
Program Description : Send a notification on MS team
for champion model publishing

**************************************************************
**************************************************************
**************************************************************/

options noquotelenmax;
filename logfile '/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/logs/notify2.log';

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
					"value": "**Tensorflow Champion Model Publishing Status**"
				},
				{
					"name": "Details:",
					"value": "Model was validated. Its image was successfully built and shipped on Openshift."
				},
				{
					"name": "Current Status:",
					"value": "System is ready to monitor your model in production..."
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