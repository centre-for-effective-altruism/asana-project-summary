#!/bin/sh

read -d '' PUPPETEER_PAYLOAD << EOF
{
  "url": "$REPORT_URL",
  "options": {
    "fullPage": true,
    "type": "png"
  },
  "gotoOptions": {
    "waitUntil": "networkidle2"
  }
}
EOF

curl -s -X POST \
  browserless:3000/screenshot \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d "$PUPPETEER_PAYLOAD" > /tmp/amicrogenesis.png

IMAGE_URL=$(curl --upload-file /tmp/amicrogenesis.png https://transfer.sh/amicrogenesis.png)

read -d '' JSON_PAYLOAD << EOF
{
  "attachments": [
    {
      "title": "Amicrogenesis Progress",
      "title_link": "$REPORT_URL",
      "fallback": "$REPORT_URL",
      "image_url": "$IMAGE_URL"
    }
  ]
}
EOF

curl -X POST -H 'Content-type: application/json' --data "$JSON_PAYLOAD" $SLACK_WEBHOOK_URL
