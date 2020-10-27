/*************************************************************
*************** Notify Champion Approval Job *****************
**************************************************************

Program Name : notify_champion_model_approval.sas
Owner : ivnard that developed this code
Program Description : Send a notification on MS team
for champion model approval

**************************************************************
**************************************************************
**************************************************************/

options noquotelenmax;
filename logfile '/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/logs/notify1.log';

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
	"summary": "Process summary message",
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
					"value": "**Tensorflow Champion Model Approval Status**"
				},
				{
					"name": "Details:",
					"value": "Analytics Leader approves Champion Model."
				},
				{
					"name": "Current Status:",
					"value": "Process is shipping Tensorflow Docker Image to production..."
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