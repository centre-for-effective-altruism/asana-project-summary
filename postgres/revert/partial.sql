BEGIN;

ALTER TABLE tasks RENAME COLUMN microgenes TO value;
ALTER TABLE tasks DROP COLUMN partial_completion;

CREATE FUNCTION generate_summary()
RETURNS daily_summary AS $$
  INSERT INTO daily_summary
  SELECT
    CURRENT_DATE AS summary_date,
    SUM(value) AS total,
    SUM(value) FILTER (WHERE completed_at IS NULL) AS incomplete,
    SUM(value) FILTER (WHERE completed_at IS NOT NULL) AS complete,
    NOW() as last_updated
  FROM tasks
  ON CONFLICT (summary_date) DO UPDATE SET
    total = EXCLUDED.total,
    incomplete = EXCLUDED.incomplete,
    complete = EXCLUDED.complete,
    last_updated = EXCLUDED.last_updated
  RETURNING *;
$$ LANGUAGE SQL VOLATILE;

COMMIT;
