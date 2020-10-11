filename resp temp;
options noquotelenmax;
proc http
  /* Substitute your webhook URL here */
  url="https://outlook.office.com/webhook/9a31df1d-da00-426f-b060-714e39b818e1@b1c14d5c-3625-45b3-a430-9552373a0c2f/IncomingWebhook/91c8e98dcfd844a9becf307c7e069e35/318842ff-9e81-44fc-9f80-57615bd6a202"
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