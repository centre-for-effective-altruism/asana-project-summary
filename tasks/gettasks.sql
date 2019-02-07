BEGIN;

WITH project_json (doc) as (
   values
    (:'projects'::json)
)
INSERT INTO tasks (gid, name, created_at, completed_at, value)
select p.*
from project_json l
  cross join lateral json_populate_recordset(null::tasks, doc) as p
on conflict (gid) do update
  set
    name = excluded.name,
    created_at = excluded.created_at,
    completed_at = excluded.completed_at,
    value = excluded.value
  ;

SELECT s.* FROM generate_summary() s;

COMMIT;
