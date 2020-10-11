options noquotelenmax;
filename logfile '/opt/demos/sas_workflow_openshift_demo/logs/notify1.log';

proc printto log=logfile;
run;

filename response TEMP;
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
  url="webhook"
  method="POST"
  in=content
  out=response;
run;


libname responses JSON fileref=response;

data _null_;
set responses.ROOT;
call symputx( "statusId", status);
run;

data _null_;
put "&statusId.";
run;

filename response clear;