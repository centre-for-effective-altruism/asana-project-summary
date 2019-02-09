#!/bin/sh

read -d '' JSON_PAYLOAD << EOF
{
  "text": "$REPORT_URL"
}
EOF

curl -X POST -H 'Content-type: application/json' --data "$JSON_PAYLOAD" $SLACK_WEBHOOK_URL
