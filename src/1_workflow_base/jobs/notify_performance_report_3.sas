/*************************************************************
*************** Notify Performance report Job ****************
**************************************************************

Program Name : notify_performance_report_3.sas
Owner : ivnard that developed this code
Program Description : Send a notification on MS team
for performance report results

**************************************************************
**************************************************************
**************************************************************/

options noquotelenmax;
filename logfile '/opt/demos/modelops-sas-tensorflow-workflow-manager-openshift/logs/notify3.log';

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
			"activityImage": "https://cdn0.iconfinder.com/data/icons/social-messaging-ui-color-shapes/128/notification-circle-red-512.png",
			"activityTitle": "",
			"activitySubtitle": "",
			"facts": [
				{
					"name": "Title:",
					"value": "**Performances Report**"
				},
				{
					"name": "Details:",
					"value": "Performance report successfully generated."
				},
				{
					"name": "Current Status:",
					"value": "Based on the report, the model is underperforming. Process will start the retraining process..."
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