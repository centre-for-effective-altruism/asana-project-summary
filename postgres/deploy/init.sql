-- Deploy amicrogenesis:init to pg

BEGIN;

ALTER TABLE tasks ADD COLUMN partial_completion DOUBLE PRECISION NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION generate_summary()
RETURNS daily_summary AS $$
  INSERT INTO daily_summary
  SELECT
    CURRENT_DATE AS summary_date,
    total,
    (uncompleted - partial_completion) AS incomplete,
    (COALESCE(completed, 0) + partial_completion) AS complete,
    NOW() AS last_updated
  FROM (
    SELECT
      SUM(value) AS total,
      SUM(value) FILTER (WHERE completed_at IS NULL) as uncompleted,
      SUM(value) FILTER (WHERE completed_at IS NOT NULL) as completed,
      SUM(partial_completion) FILTER (WHERE completed_at IS NULL) as partial_completion
    FROM tasks
  ) agg
  ON CONFLICT (summary_date) DO UPDATE SET
    total = EXCLUDED.total,
    incomplete = EXCLUDED.incomplete,
    complete = EXCLUDED.complete,
    last_updated = EXCLUDED.last_updated
  RETURNING *;
$$ LANGUAGE SQL VOLATILE;

COMMIT;
