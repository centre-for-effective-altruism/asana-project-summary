#!/bin/sh

TIMESTAMP=`date '+%Y_%m_%d__%H_%M_%S'`
TMPFILE=/tmp/amicrogenesis.png
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
  -d "$PUPPETEER_PAYLOAD" > $TMPFILE

B2_UPLOAD=$(b2 upload-file --noProgress amicrogenesis $TMPFILE "amicrogenesis-$TIMESTAMP.png")
IMAGE_URL=$(echo "$B2_UPLOAD" | head -1 | sed -r 's/URL by file name: (.+)$/\1/')

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

rm $TMPFILE
