-- Verify amicrogenesis:init on pg

BEGIN;

SELECT
  gid, name, created_at, completed_at, value
FROM public.tasks WHERE FALSE;

SELECT
  summary_date, total, incomplete, complete, last_updated
FROM public.daily_summary WHERE FALSE;

SELECT has_function_privilege('public.generate_summary()', 'execute');

ROLLBACK;
