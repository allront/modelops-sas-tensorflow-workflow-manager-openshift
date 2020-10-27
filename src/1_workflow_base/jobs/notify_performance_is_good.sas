/*************************************************************
*************** Notify Performance report Job ****************
**************************************************************

Program Name : notify_performance_is_good.sas
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
			"activityImage": "https://cdn0.iconfinder.com/data/icons/social-messaging-ui-color-shapes/128/notification-circle-blue-512.png",
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
					"value": "Based on the report, the model is performing well. Process will move to the next time period for analysis."
				}
			]
		}
	]
}
;
run;

proc http
  /* Substitute your webhook URL here */
  url="https://outlook.office.com/webhook/9a31df1d-da00-426f-b060-714e39b818e1@b1c14d5c-3625-45b3-a430-9552373a0c2f/IncomingWebhook/91c8e98dcfd844a9becf307c7e069e35/318842ff-9e81-44fc-9f80-57615bd6a202"
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