-- Deploy amicrogenesis:init to pg

BEGIN;

CREATE TABLE tasks (
  gid BIGINT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  value DOUBLE PRECISION NOT NULL DEFAULT 0
);

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
