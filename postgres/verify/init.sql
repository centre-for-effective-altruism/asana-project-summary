-- Verify amicrogenesis:init on pg

BEGIN;

SELECT
  gid, name, created_at, completed_at, value, partial_completion
FROM public.tasks WHERE FALSE;

SELECT has_function_privilege('public.generate_summary()', 'execute');

ROLLBACK;
