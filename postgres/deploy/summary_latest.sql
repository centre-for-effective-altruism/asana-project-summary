-- Deploy amicrogenesis:summary_latest to pg

BEGIN;

CREATE VIEW daily_summary_latest AS (
  SELECT * FROM daily_summary ORDER BY summary_date DESC LIMIT 1
);

COMMIT;
