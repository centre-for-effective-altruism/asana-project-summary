-- Deploy amicrogenesis:init to pg

BEGIN;

-- TODO; how to migrate
CREATE TABLE tasks (
  gid BIGINT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  microgenes DOUBLE PRECISION NOT NULL DEFAULT 0,
  partial_completion DOUBLE PRECISION NOT NULL DEFAULT 0
);

-- TODO; how does this handle weird removals / adjustments etc
-- TODO; doc
CREATE TABLE daily_summary (
  summary_date DATE PRIMARY KEY DEFAULT CURRENT_DATE,
  total DOUBLE PRECISION,
  incomplete DOUBLE PRECISION,
  complete DOUBLE PRECISION,
  last_updated TIMESTAMPTZ
);


CREATE FUNCTION generate_summary()
RETURNS daily_summary AS $$
  INSERT INTO daily_summary
  SELECT
    CURRENT_DATE AS summary_date,
    total,
    (uncompleted_microgenes - uncompleted_partial_completion) AS incomplete,
    (COALESCE(completed_microgenes, 0) + uncompleted_partial_completion) AS complete,
    NOW() AS last_updated
  FROM (
    SELECT
      SUM(microgenes) AS total,
      SUM(microgenes) FILTER (WHERE completed_at IS NULL) as uncompleted_microgenes,
      SUM(microgenes) FILTER (WHERE completed_at IS NOT NULL) as completed_microgenes,
      SUM(partial_completion) FILTER (WHERE completed_at IS NULL) as uncompleted_partial_completion
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
