#!/bin/sh

ENV_FILE=../.env
if [ -e $ENV_FILE ]
    then
        export $(cat $ENV_FILE | xargs)
fi

# see https://asana.com/developers/api-reference/tasks
TASK_FIELDS=name,custom_fields,created_at,completed_at

ASANA_PROJECTS=$(curl -s -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" https://app.asana.com/api/1.0/projects/$ASANA_PROJECT_GID/tasks?opt_fields=$TASK_FIELDS | jq .)

#echo $ASANA_PROJECTS | jq '.data | .[0]'
#echo $ASANA_MICROGENE_FIELD_GID

read -d '' JQ_PROJECTS << EOF
.data |
[
  .[] |
  select(.name|test("[^:]$")) |
  . + {
    microgenes: .custom_fields |
      .[] |
      select(.gid == \"$ASANA_MICROGENE_FIELD_GID\") |
      .number_value|(. // 0)
  } |
  . + {
    partial_completion: .custom_fields |
      .[] |
      select(.gid == \"$ASANA_PARTIAL_COMPLETION_FIELD_GID\") |
      .number_value|(. // 0)
  } |
  delpaths([ ["id"], ["custom_fields"] ])
]
EOF
# TODO; can I get rid of |(.

# TODO; why is this called this
PROJECTS=$(echo $ASANA_PROJECTS | jq -r "$JQ_PROJECTS")

#echo $ASANA_PROJECTS | jq "$JQ_PROJECTS"

psql -X -v ON_ERROR_STOP=1 -v projects="$PROJECTS" postgres://postgres@postgres/postgres < gettasks.sql
