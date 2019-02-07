#!/bin/sh

# see https://asana.com/developers/api-reference/tasks
TASK_FIELDS=name,custom_fields,created_at,completed_at
ASANA_PROJECTS=$(curl -s -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" https://app.asana.com/api/1.0/projects/$ASANA_PROJECT_GID/tasks?opt_fields=$TASK_FIELDS | jq .)

read -d '' JQ_PROJECTS << EOF
.data|
[
  .[]|select(.name|test("[^:]$"))|
  . + {
    value: .custom_fields|.[]
      |select(.gid = $ASANA_CUSTOM_FIELD_GID)
      |.number_value|(. // 0)
  }|
  delpaths([ ["id"], ["custom_fields"] ])
]
EOF

PROJECTS=$(echo $ASANA_PROJECTS | jq -r "$JQ_PROJECTS")

psql -X -v ON_ERROR_STOP=1 -v projects="$PROJECTS" postgres://postgres@postgres/postgres < gettasks.sql
