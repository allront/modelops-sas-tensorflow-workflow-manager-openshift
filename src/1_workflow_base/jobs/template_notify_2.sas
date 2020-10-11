filename resp temp;
options noquotelenmax;
proc http
  /* Substitute your webhook URL here */
  url="<webhook>"
  method="POST"
  in=
  '{
      "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
      "type": "AdaptiveCard",
      "version": "1.0",
      "summary": "SAS Workflow Manager Notification",
      "text": "**Tensorflow Model successfully deployed!**"
  }'
  out=resp;
run;