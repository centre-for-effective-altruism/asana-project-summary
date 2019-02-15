-- Revert amicrogenesis:init from pg

BEGIN;

DROP FUNCTION generate_summary();

DROP TABLE daily_summary;

DROP TABLE tasks;

COMMIT;
