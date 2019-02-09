-- Verify amicrogenesis:summary_latest on pg

BEGIN;

SELECT
  summary_date, total, incomplete, complete, last_updated
FROM public.daily_summary_latest WHERE FALSE;


ROLLBACK;
