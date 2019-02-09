-- Revert amicrogenesis:summary_latest from pg

BEGIN;

DROP VIEW daily_summary_latest;

COMMIT;
