options noquotelenmax;
filename logfile '/opt/demos/sas_workflow_openshift_demo/logs/notify3.log';

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