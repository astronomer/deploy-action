-- Stand-in content for the non-DAG bundle deployed by the e2e tests.
-- A non-DAG bundle is any directory mounted into Airflow for DAGs to read at runtime,
-- so the contents only need to exist, not to be valid for any particular engine.
SELECT 1 AS example;
